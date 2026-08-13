import Foundation

final class FetchNearCafeUseCase {

  struct Page {
    let cafes: [NearCafeEntity]
    let pageableCount: Int
    let isEnd: Bool
  }

  private let dataSource: KakaoAPIDataSource

  init(dataSource: KakaoAPIDataSource = .shared) {
    self.dataSource = dataSource
  }

  func execute(latitude: Double,
               longitude: Double,
               query: String,
               page: Int,
               completion: @escaping (Result<Page, AppError>) -> Void) {
    dataSource.fetchCafeInfo(pos: (latitude, longitude), query: query, page: page) { result in
      switch result {
      case .success(let response):
        let cafes = response.documents.map { doc -> NearCafeEntity in
          NearCafeEntity(
            name: doc.placeName,
            address: doc.roadAddressName,
            latitude: Double(doc.y) ?? 0,
            longitude: Double(doc.x) ?? 0,
            placeUrl: doc.placeUrl,
            distance: doc.distance.isEmpty ? " - " : doc.distance)
        }
        completion(.success(Page(cafes: cafes, pageableCount: response.meta.pageableCount, isEnd: response.meta.isEnd)))

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
