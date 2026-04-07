import Foundation

struct CafeEntity: Equatable {
  let id: String
  let name: String
  let visitDate: Date
  let comment: String?
  let rate: Int

  static func == (lhs: CafeEntity, rhs: CafeEntity) -> Bool {
    return lhs.id == rhs.id
  }
}
