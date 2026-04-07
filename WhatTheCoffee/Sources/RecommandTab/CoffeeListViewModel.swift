import UIKit

final class CoffeeListViewModel {

  // MARK: - Properties
  private let useCase: ManageCoffeeListUseCase
  private let imageManager = ImageManager.shared

  var coffeeList: [CoffeeEntity] = []

  // MARK: - Binding
  var onCoffeeListUpdated: (() -> Void)?

  // MARK: - Init
  init(useCase: ManageCoffeeListUseCase) {
    self.useCase = useCase
  }

  // MARK: - Data
  var isEmpty: Bool { coffeeList.isEmpty }
  var count: Int { coffeeList.count }

  func coffee(at index: Int) -> CoffeeEntity {
    return coffeeList[index]
  }

  func coffeeImage(at index: Int) -> UIImage {
    let coffee = coffeeList[index]
    return imageManager.loadImage(type: .coffee, imageName: "coffee_\(coffee.id).jpg") ?? UIImage.randomCoffeeImage
  }

  func fetchData() {
    coffeeList = useCase.fetchAll()
    onCoffeeListUpdated?()
  }

  func deleteCoffee(at index: Int) {
    let coffee = coffeeList[index]
    imageManager.deleteImage(type: .coffee, imageName: "coffee_\(coffee.id).jpg")
    useCase.remove(id: coffee.id)
    fetchData()
  }
}
