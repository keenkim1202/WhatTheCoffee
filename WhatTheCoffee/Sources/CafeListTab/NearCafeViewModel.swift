import Foundation

final class NearCafeViewModel {

  // MARK: - Properties
  private let perPage: Int = 15

  var nearCafeList: [NearCafeEntity] = []
  var page: Int = 1
  var pageableCount: Int = 0
  var isEnd: Bool = false
  var queryText: String?

  // MARK: - Binding
  var onNearCafeListUpdated: (() -> Void)?

  // MARK: - Data
  var isEmpty: Bool {
    return nearCafeList.isEmpty
  }

  var count: Int {
    return nearCafeList.count
  }

  func cafe(at index: Int) -> NearCafeEntity {
    return nearCafeList[index]
  }

  func shouldPrefetch(at index: Int) -> Bool {
    return nearCafeList.count - 1 == index && pageableCount > perPage * page
  }

  func fetchData(latitude: Double, longitude: Double, query: String = "카페", page: Int = 1) {
    KakaoAPIDataSource.shared.fetchCafeInfo(pos: (latitude, longitude), query: query, page: page) { [weak self] code, response in
      guard let self = self, let response = response else { return }

      self.pageableCount = response.meta.pageableCount
      self.isEnd = response.meta.isEnd

      for doc in response.documents {
        let distance = doc.distance.isEmpty ? " - " : doc.distance
        let cafe = NearCafeEntity(
          name: doc.placeName,
          address: doc.roadAddressName,
          latitude: Double(doc.y) ?? 0,
          longitude: Double(doc.x) ?? 0,
          placeUrl: doc.placeUrl,
          distance: distance)
        self.nearCafeList.append(cafe)
      }

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
