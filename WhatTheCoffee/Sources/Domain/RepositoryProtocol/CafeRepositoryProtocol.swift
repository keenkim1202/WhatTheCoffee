import Foundation

protocol CafeRepositoryProtocol {
  var count: Int { get }

  @discardableResult
  func add(name: String, visitDate: Date, comment: String?, rate: Int, latitude: Double?, longitude: Double?) -> CafeEntity
  func update(id: String, name: String, visitDate: Date, comment: String?, rate: Int, latitude: Double?, longitude: Double?)
  func updateClosedStatus(id: String, isClosed: Bool)
  func remove(id: String)
  func fetch() -> [CafeEntity]
  func search(query: String) -> [CafeEntity]
}

extension CafeRepositoryProtocol {
  @discardableResult
  func add(name: String, visitDate: Date = Date(), comment: String?, rate: Int) -> CafeEntity {
    return add(name: name, visitDate: visitDate, comment: comment, rate: rate, latitude: nil, longitude: nil)
  }

  func update(id: String, name: String, visitDate: Date, comment: String?, rate: Int) {
    update(id: id, name: name, visitDate: visitDate, comment: comment, rate: rate, latitude: nil, longitude: nil)
  }
}
