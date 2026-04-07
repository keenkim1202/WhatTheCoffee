import Foundation

protocol Environment {
  var coffeeRepository: CoffeeRepository { get }
  var cafeRepository: CafeRepository { get }
}

final class AppEnvironment: Environment {
  var coffeeRepository: CoffeeRepository
  var cafeRepository: CafeRepository
  
  init(
    coffeeRepository: CoffeeRepository,
    cafeRepsitory: CafeRepository) {
      self.coffeeRepository = coffeeRepository
      self.cafeRepository = cafeRepsitory
    }
}
