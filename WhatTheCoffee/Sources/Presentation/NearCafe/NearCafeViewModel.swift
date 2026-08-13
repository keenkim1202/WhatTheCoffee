import UIKit
import CoreLocation

final class NearCafeViewModel {

  // MARK: - Properties
  private let perPage: Int = 15
  private let useCase: FetchNearCafeUseCase
  private let recordsUseCase: ManageRecordsUseCase
  private let imageUseCase: ManageImageUseCase

  /// 같은 가게로 볼 거리. 검색으로 기록하면 좌표가 같은 출처라 사실상 일치한다.
  private let samePlaceDistance: CLLocationDistance = 100

  /// 목록을 그릴 때마다 Realm을 뒤지지 않도록 한 번 읽어 들고 있는다.
  private var recordedCafes: [CafeEntity] = []

  var nearCafeList: [NearCafeEntity] = []
  var page: Int = 1
  var pageableCount: Int = 0
  var isEnd: Bool = false
  var queryText: String?

  // MARK: - Binding
  var onNearCafeListUpdated: (() -> Void)?
  var onStatusChanged: ((ListStatusView.State) -> Void)?

  private(set) var isLoading = false

  /// 요청 세대. 새 검색이 시작되면 올려서 앞선 요청의 응답을 버린다.
  private var requestToken = 0

  // MARK: - Init
  init(useCase: FetchNearCafeUseCase = FetchNearCafeUseCase(),
       recordsUseCase: ManageRecordsUseCase,
       imageUseCase: ManageImageUseCase) {
    self.useCase = useCase
    self.recordsUseCase = recordsUseCase
    self.imageUseCase = imageUseCase
  }

  // MARK: - Data
  var isEmpty: Bool { nearCafeList.isEmpty }
  var count: Int { nearCafeList.count }

  func cafe(at index: Int) -> NearCafeEntity {
    return nearCafeList[index]
  }

  func reloadRecords() {
    recordedCafes = recordsUseCase.fetchAll()
  }

  /// 이미 기록해둔 가게면 그때 남긴 사진을 쓴다. 없으면 nil을 돌려 기본 이미지를 쓰게 한다.
  /// 한 가게를 여러 번 기록했을 수 있고 사진을 안 넣은 기록도 있어서,
  /// 최근 것부터 훑어 사진이 실제로 있는 기록을 쓴다.
  func recordedImage(for cafe: NearCafeEntity) -> UIImage? {
    return matchedRecords(for: cafe)
      .lazy
      .compactMap { self.imageUseCase.loadCafeImage(id: $0.id) }
      .first
  }

  /// 이름이 같고 좌표가 가까운 기록을 최근 순으로 찾는다.
  /// 이름만 보면 같은 이름의 다른 지점이 걸리고, 좌표만 보면
  /// 현재 위치로 남긴 기록이 옆 가게에 잘못 붙는다.
  private func matchedRecords(for cafe: NearCafeEntity) -> [CafeEntity] {
    let target = CLLocation(latitude: cafe.latitude, longitude: cafe.longitude)
    let name = Self.normalized(cafe.name)

    return recordedCafes.filter { record in
      guard Self.normalized(record.name) == name,
            let latitude = record.latitude,
            let longitude = record.longitude else { return false }
      return CLLocation(latitude: latitude, longitude: longitude).distance(from: target) <= samePlaceDistance
    }
  }

  private static func normalized(_ name: String) -> String {
    return name.replacingOccurrences(of: " ", with: "").lowercased()
  }

  func shouldPrefetch(at index: Int) -> Bool {
    return nearCafeList.count - 1 == index && pageableCount > perPage * page
  }

  func fetchData(latitude: Double, longitude: Double, query: String = "카페", page: Int = 1) {
    // 새 검색을 막으면 앞선 요청의 결과가 비워둔 목록에 채워져 엉뚱한 화면이 된다.
    // 막는 대신 세대를 기억해두고, 늦게 온 응답을 버린다.
    isLoading = true
    let token = requestToken

    if nearCafeList.isEmpty {
      onStatusChanged?(.loading("근처 카페를 찾는 중이에요"))
    }

    useCase.execute(latitude: latitude, longitude: longitude, query: query, page: page) { [weak self] result in
      guard let self else { return }

      DispatchQueue.main.async {
        // 그 사이 새 검색이 시작됐으면 이 응답은 버린다.
        guard token == self.requestToken else { return }
        self.isLoading = false

        switch result {
        case .success(let page):
          self.pageableCount = page.pageableCount
          self.isEnd = page.isEnd
          self.nearCafeList.append(contentsOf: page.cafes)
          self.onStatusChanged?(self.nearCafeList.isEmpty ? .empty("근처에 카페가 없어요 🥲") : .hidden)

        case .failure(let error):
          // 이미 받아둔 목록이 있으면 그건 남겨두고 알리기만 한다.
          self.onStatusChanged?(self.nearCafeList.isEmpty ? .failed(error) : .hidden)
          self.onLoadFailed?(error)
        }

        self.onNearCafeListUpdated?()
      }
    }
  }

  /// 목록이 이미 있는 상태에서 실패했을 때 화면이 알아서 처리하도록 알린다.
  var onLoadFailed: ((AppError) -> Void)?

  func showLocationStatus(_ state: ListStatusView.State) {
    onStatusChanged?(state)
  }

  func reset() {
    // 진행 중인 응답이 새 목록에 섞이지 않도록 세대를 올린다.
    requestToken += 1
    isLoading = false
    nearCafeList.removeAll()
    pageableCount = 0
    page = 1
  }

  func loadNextPage(latitude: Double, longitude: Double) {
    // 요청이 받아들여질 때만 페이지를 넘긴다.
    // 먼저 올려두면 거절된 요청의 페이지가 통째로 빠진다.
    guard !isLoading else { return }
    page += 1
    if let text = queryText {
      fetchData(latitude: latitude, longitude: longitude, query: text, page: page)
    } else {
      fetchData(latitude: latitude, longitude: longitude, page: page)
    }
  }
}
