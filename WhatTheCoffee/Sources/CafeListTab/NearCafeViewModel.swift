import Foundation

final class NearCafeViewModel {

  // MARK: - Properties
  private let perPage: Int = 15
  private let useCase: FetchNearCafeUseCase

  var nearCafeList: [NearCafeEntity] = []
  var page: Int = 1
  var pageableCount: Int = 0
  var isEnd: Bool = false
  var queryText: String?

  // MARK: - Binding
  var onNearCafeListUpdated: (() -> Void)?

  // MARK: - Init
  init(useCase: FetchNearCafeUseCase = FetchNearCafeUseCase()) {
    self.useCase = useCase
  }

  // MARK: - Data
  var isEmpty: Bool { nearCafeList.isEmpty }
  var count: Int { nearCafeList.count }

  func cafe(at index: Int) -> NearCafeEntity {
    return nearCafeList[index]
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
