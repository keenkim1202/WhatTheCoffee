import Foundation

struct CafeEntity: Equatable {
  let id: String
  let name: String
  let visitDate: Date
  let comment: String?
  let rate: Int
  let latitude: Double?
  let longitude: Double?
  let isClosed: Bool
  let address: String?
  /// 방문한 날들. 오래된 순.
  let visitDates: [Date]
  /// 그 카페에서 마신 커피.
  let coffeeName: String?
  let coffeeId: String?

  var visitCount: Int {
    return max(1, visitDates.count)
  }

  var hasLocation: Bool {
    return latitude != nil && longitude != nil
  }

  static func == (lhs: CafeEntity, rhs: CafeEntity) -> Bool {
    return lhs.id == rhs.id
  }
}
