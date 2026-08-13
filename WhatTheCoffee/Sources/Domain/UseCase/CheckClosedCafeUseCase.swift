import Foundation

final class CheckClosedCafeUseCase {
  private let repository: CafeRepositoryProtocol
  private let apiDataSource: KakaoAPIDataSource

  init(repository: CafeRepositoryProtocol, apiDataSource: KakaoAPIDataSource = .shared) {
    self.repository = repository
    self.apiDataSource = apiDataSource
  }

  func checkAll(completion: @escaping (Int) -> Void) {
    let cafes = repository.fetch().filter { $0.hasLocation }
    var closedCount = 0
    let group = DispatchGroup()

    for cafe in cafes {
      guard let cafeLat = cafe.latitude, let cafeLng = cafe.longitude else { continue }
      group.enter()
      apiDataSource.fetchCafeInfo(pos: (cafeLat, cafeLng), query: cafe.name, page: 1) { [weak self] result in
        defer { group.leave() }

        // 통신이 실패한 것과 검색 결과가 없는 것은 다르다.
        // 실패를 폐점으로 단정하면 멀쩡한 카페가 문 닫은 것으로 표시된다.
        guard case .success(let response) = result else { return }

        let isFound = response.documents.contains { doc in
          let lat = Double(doc.y) ?? 0
          let lng = Double(doc.x) ?? 0
          let distance = Self.calculateDistance(lat1: cafeLat, lng1: cafeLng, lat2: lat, lng2: lng)
          return distance < 200
        }

        let isClosed = !isFound
        if isClosed { closedCount += 1 }
        self?.repository.updateClosedStatus(id: cafe.id, isClosed: isClosed)
      }
    }

    group.notify(queue: .main) {
      completion(closedCount)
    }
  }

  private static func calculateDistance(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
    let R = 6371000.0
    let dLat = (lat2 - lat1) * .pi / 180
    let dLng = (lng2 - lng1) * .pi / 180
    let a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
      sin(dLng / 2) * sin(dLng / 2)
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return R * c
  }
}
