import UIKit

final class AddCoffeeViewModel {

  enum ViewType {
    case add
    case update
  }

  // MARK: - Properties
  private let useCase: ManageCoffeeListUseCase
  private let imageUseCase: ManageImageUseCase

  let viewType: ViewType
  let coffee: CoffeeEntity?

  // MARK: - Init
  init(useCase: ManageCoffeeListUseCase, imageUseCase: ManageImageUseCase, coffee: CoffeeEntity? = nil) {
    self.useCase = useCase
    self.imageUseCase = imageUseCase
    self.coffee = coffee
    self.viewType = coffee != nil ? .update : .add
  }

  // MARK: - Data
  var title: String {
    return viewType == .update ? "커피 수정" : "커피 추가"
  }

  var currentImage: UIImage {
    if let coffee = coffee {
      return imageUseCase.loadCoffeeImage(id: coffee.id) ?? UIImage.randomCoffeeImage
    }
    return UIImage.randomCoffeeImage
  }

  var currentName: String? { coffee?.name }

  func save(name: String, image: UIImage?) {
    if viewType == .update, let coffee = coffee {
      useCase.update(id: coffee.id, name: name)

      if let image = image, image != UIImage.randomCoffeeImage {
        imageUseCase.saveCoffeeImage(id: coffee.id, image: image)
      } else {
        if imageUseCase.loadCoffeeImage(id: coffee.id) != nil {
          imageUseCase.deleteCoffeeImage(id: coffee.id)
        }
      }
    } else {
      let newCoffee = useCase.add(name: name)

      if let image = image, image != UIImage.randomCoffeeImage {
        imageUseCase.saveCoffeeImage(id: newCoffee.id, image: image)
      }
    }
  }
}
