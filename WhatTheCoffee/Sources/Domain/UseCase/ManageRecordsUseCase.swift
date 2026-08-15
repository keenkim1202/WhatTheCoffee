import Foundation

final class ManageRecordsUseCase {
  private let repository: CafeRepositoryProtocol

  init(repository: CafeRepositoryProtocol) {
    self.repository = repository
  }

  func fetchAll() -> [CafeEntity] {
    return repository.fetch()
  }

  @discardableResult
  func add(name: String, visitDate: Date, comment: String?, rate: Int, latitude: Double?, longitude: Double?, address: String?, visitDates: [Date]) -> CafeEntity {
    return repository.add(name: name, visitDate: visitDate, comment: comment, rate: rate, latitude: latitude, longitude: longitude, address: address, visitDates: visitDates)
  }

  func update(id: String, name: String, visitDate: Date, comment: String?, rate: Int, latitude: Double?, longitude: Double?, address: String?, visitDates: [Date]) {
    repository.update(id: id, name: name, visitDate: visitDate, comment: comment, rate: rate, latitude: latitude, longitude: longitude, address: address, visitDates: visitDates)
  }

  func updateClosedStatus(id: String, isClosed: Bool) {
    repository.updateClosedStatus(id: id, isClosed: isClosed)
  }

  func remove(id: String) {
    repository.remove(id: id)
  }

  func search(query: String) -> [CafeEntity] {
    return repository.search(query: query)
  }
}
