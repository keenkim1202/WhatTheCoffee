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

  var hasLocation: Bool {
    return latitude != nil && longitude != nil
  }

  static func == (lhs: CafeEntity, rhs: CafeEntity) -> Bool {
    return lhs.id == rhs.id
  }
}
