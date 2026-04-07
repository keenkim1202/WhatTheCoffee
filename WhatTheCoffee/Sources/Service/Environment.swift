import Foundation

protocol Environment {
  var coffeeRepository: CoffeeRepositoryProtocol { get }
  var cafeRepository: CafeRepositoryProtocol { get }
}

final class AppEnvironment: Environment {
  var coffeeRepository: CoffeeRepositoryProtocol
  var cafeRepository: CafeRepositoryProtocol

  init(
    coffeeRepository: CoffeeRepositoryProtocol,
    cafeRepository: CafeRepositoryProtocol) {
      self.coffeeRepository = coffeeRepository
      self.cafeRepository = cafeRepository
    }
}
