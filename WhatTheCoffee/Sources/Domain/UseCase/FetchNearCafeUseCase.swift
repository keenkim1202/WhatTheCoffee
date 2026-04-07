import Foundation

final class FetchNearCafeUseCase {
  private let dataSource: KakaoAPIDataSource

  init(dataSource: KakaoAPIDataSource = .shared) {
    self.dataSource = dataSource
  }

  func execute(latitude: Double, longitude: Double, query: String, page: Int, completion: @escaping ([NearCafeEntity], Int, Bool) -> Void) {
    dataSource.fetchCafeInfo(pos: (latitude, longitude), query: query, page: page) { code, response in
      guard let response = response else {
        completion([], 0, true)
        return
      }

      let cafes = response.documents.map { doc -> NearCafeEntity in
        let distance = doc.distance.isEmpty ? " - " : doc.distance
        return NearCafeEntity(
          name: doc.placeName,
          address: doc.roadAddressName,
          latitude: Double(doc.y) ?? 0,
          longitude: Double(doc.x) ?? 0,
          placeUrl: doc.placeUrl,
          distance: distance)
      }

      completion(cafes, response.meta.pageableCount, response.meta.isEnd)
    }
  }
}
