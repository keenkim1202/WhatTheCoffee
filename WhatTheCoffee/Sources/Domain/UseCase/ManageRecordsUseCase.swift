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
  func add(name: String, visitDate: Date, comment: String?, rate: Int) -> CafeEntity {
    return repository.add(name: name, visitDate: visitDate, comment: comment, rate: rate)
  }

  func update(id: String, name: String, visitDate: Date, comment: String?, rate: Int) {
    repository.update(id: id, name: name, visitDate: visitDate, comment: comment, rate: rate)
  }

  func remove(id: String) {
    repository.remove(id: id)
  }

  func search(query: String) -> [CafeEntity] {
    return repository.search(query: query)
  }
}
