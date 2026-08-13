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
    useCase.execute(latitude: latitude, longitude: longitude, query: query, page: page) { [weak self] cafes, pageableCount, isEnd in
      guard let self = self else { return }
      self.pageableCount = pageableCount
      self.isEnd = isEnd
      self.nearCafeList.append(contentsOf: cafes)

      DispatchQueue.main.async {
        self.onNearCafeListUpdated?()
      }
    }
  }

  func reset() {
    nearCafeList.removeAll()
    pageableCount = 0
    page = 1
  }

  func loadNextPage(latitude: Double, longitude: Double) {
    page += 1
    if let text = queryText {
      fetchData(latitude: latitude, longitude: longitude, query: text, page: page)
    } else {
      fetchData(latitude: latitude, longitude: longitude, page: page)
    }
  }
}
