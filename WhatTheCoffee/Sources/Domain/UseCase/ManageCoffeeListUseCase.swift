import Foundation

final class ManageCoffeeListUseCase {
  private let repository: CoffeeRepositoryProtocol

  init(repository: CoffeeRepositoryProtocol) {
    self.repository = repository
  }

  func fetchAll() -> [CoffeeEntity] {
    return repository.fetch()
  }

  @discardableResult
  func add(name: String) -> CoffeeEntity {
    return repository.add(name: name)
  }

  func update(id: String, name: String) {
    repository.update(id: id, name: name)
  }

  func remove(id: String) {
    repository.remove(id: id)
  }
}
