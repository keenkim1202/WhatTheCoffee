import Foundation

enum CoffeeMapper {
  static func toEntity(_ object: Coffee) -> CoffeeEntity {
    CoffeeEntity(
      id: object._id.stringValue,
      name: object.name,
      date: object.date)
  }
}
