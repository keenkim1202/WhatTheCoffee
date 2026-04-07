import UIKit

final class CoffeeListViewModel {

  // MARK: - Properties
  private let useCase: ManageCoffeeListUseCase
  private let imageUseCase: ManageImageUseCase

  var coffeeList: [CoffeeEntity] = []

  // MARK: - Binding
  var onCoffeeListUpdated: (() -> Void)?

  // MARK: - Init
  init(useCase: ManageCoffeeListUseCase, imageUseCase: ManageImageUseCase) {
    self.useCase = useCase
    self.imageUseCase = imageUseCase
  }

  // MARK: - Data
  var isEmpty: Bool { coffeeList.isEmpty }
  var count: Int { coffeeList.count }

  func coffee(at index: Int) -> CoffeeEntity {
    return coffeeList[index]
  }

  func coffeeImage(at index: Int) -> UIImage {
    let coffee = coffeeList[index]
    return imageUseCase.loadCoffeeImage(id: coffee.id) ?? UIImage.randomCoffeeImage
  }

  func fetchData() {
    coffeeList = useCase.fetchAll()
    onCoffeeListUpdated?()
  }

  func deleteCoffee(at index: Int) {
    let coffee = coffeeList[index]
    imageUseCase.deleteCoffeeImage(id: coffee.id)
    useCase.remove(id: coffee.id)
    fetchData()
  }
}
