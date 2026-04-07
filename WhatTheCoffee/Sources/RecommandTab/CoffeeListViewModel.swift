import UIKit

final class CoffeeListViewModel {

  // MARK: - Properties
  private let coffeeRepository: CoffeeRepositoryProtocol
  private let imageManager = ImageManager.shared

  var coffeeList: [CoffeeEntity] = []

  // MARK: - Binding
  var onCoffeeListUpdated: (() -> Void)?

  // MARK: - Init
  init(coffeeRepository: CoffeeRepositoryProtocol) {
    self.coffeeRepository = coffeeRepository
  }

  // MARK: - Data
  var isEmpty: Bool {
    return coffeeList.isEmpty
  }

  var count: Int {
    return coffeeList.count
  }

  func coffee(at index: Int) -> CoffeeEntity {
    return coffeeList[index]
  }

  func coffeeImage(at index: Int) -> UIImage {
    let coffee = coffeeList[index]
    return imageManager.loadImage(type: .coffee, imageName: "coffee_\(coffee.id).jpg") ?? UIImage.randomCoffeeImage
  }

  func fetchData() {
    coffeeList = coffeeRepository.fetch()
    onCoffeeListUpdated?()
  }

  func deleteCoffee(at index: Int) {
    let coffee = coffeeList[index]
    imageManager.deleteImage(type: .coffee, imageName: "coffee_\(coffee.id).jpg")
    coffeeRepository.remove(id: coffee.id)
    fetchData()
  }
}
