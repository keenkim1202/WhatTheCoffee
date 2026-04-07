import Foundation

protocol CafeRepositoryProtocol {
  var count: Int { get }

  func add(name: String, visitDate: Date, comment: String?, rate: Int) -> CafeEntity
  func update(id: String, name: String, visitDate: Date, comment: String?, rate: Int)
  func remove(id: String)
  func fetch() -> [CafeEntity]
  func search(query: String) -> [CafeEntity]
}
