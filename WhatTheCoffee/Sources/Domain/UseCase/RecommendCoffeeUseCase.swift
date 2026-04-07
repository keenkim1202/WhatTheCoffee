import Foundation

final class RecommendCoffeeUseCase {
  private let repository: CoffeeRepositoryProtocol

  init(repository: CoffeeRepositoryProtocol) {
    self.repository = repository
  }

  func fetchAll() -> [CoffeeEntity] {
    return repository.fetch()
  }

  func pickRandom(from list: [CoffeeEntity], excluding current: CoffeeEntity?) -> CoffeeEntity? {
    guard !list.isEmpty else { return nil }
    if list.count == 1 { return list[0] }

    guard let current = current else {
      return list[Int.random(in: 0..<list.count)]
    }

    var index = Int.random(in: 0..<list.count)
    while list[index].name == current.name {
      index = Int.random(in: 0..<list.count)
    }
    return list[index]
  }
}
