import Foundation

struct CoffeeEntity: Equatable {
  let id: String
  let name: String
  let date: Date

  static func == (lhs: CoffeeEntity, rhs: CoffeeEntity) -> Bool {
    return lhs.id == rhs.id
  }
}
