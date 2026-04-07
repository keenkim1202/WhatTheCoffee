import UIKit

final class CoffeeListViewModel {

  // MARK: - Properties
  private let coffeeRepository: CoffeeRepositoryType
  private let imageManager = ImageManager.shared

  var coffeeList: [Coffee] = []

  // MARK: - Binding
  var onCoffeeListUpdated: (() -> Void)?

  // MARK: - Init
  init(coffeeRepository: CoffeeRepositoryType) {
    self.coffeeRepository = coffeeRepository
  }

  // MARK: - Data
  var isEmpty: Bool {
    return coffeeList.isEmpty
  }

  var count: Int {
    return coffeeList.count
  }

  func coffee(at index: Int) -> Coffee {
    return coffeeList[index]
  }

  func coffeeImage(at index: Int) -> UIImage {
    let coffee = coffeeList[index]
    return imageManager.loadImage(type: .coffee, imageName: "coffee_\(coffee._id).jpg") ?? UIImage.randomCoffeeImage
  }

  func fetchData() {
    coffeeList = coffeeRepository.fetch()
    onCoffeeListUpdated?()
  }

  func deleteCoffee(at index: Int) {
    let coffee = coffeeList[index]
    imageManager.deleteImage(type: .coffee, imageName: "coffee_\(coffee._id).jpg")
    coffeeRepository.remove(item: coffee)
    fetchData()
  }
}
