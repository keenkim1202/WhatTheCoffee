import Foundation

protocol CoffeeRepositoryProtocol {
  var count: Int { get }

  func add(name: String) -> CoffeeEntity
  func update(id: String, name: String)
  func remove(id: String)
  func fetch() -> [CoffeeEntity]
  func isContain(id: String) -> Bool
}
