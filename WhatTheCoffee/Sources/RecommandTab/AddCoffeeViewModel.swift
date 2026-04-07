import UIKit

final class AddCoffeeViewModel {

  enum ViewType {
    case add
    case update
  }

  // MARK: - Properties
  private let coffeeRepository: CoffeeRepositoryProtocol
  private let imageManager = ImageManager.shared

  let viewType: ViewType
  let coffee: CoffeeEntity?

  // MARK: - Init
  init(coffeeRepository: CoffeeRepositoryProtocol, coffee: CoffeeEntity? = nil) {
    self.coffeeRepository = coffeeRepository
    self.coffee = coffee
    self.viewType = coffee != nil ? .update : .add
  }

  // MARK: - Data
  var title: String {
    return viewType == .update ? "커피 수정" : "커피 추가"
  }

  var currentImage: UIImage {
    if let coffee = coffee {
      return imageManager.loadImage(type: .coffee, imageName: "coffee_\(coffee.id).jpg") ?? UIImage.randomCoffeeImage
    }
    return UIImage.randomCoffeeImage
  }

  var currentName: String? {
    return coffee?.name
  }

  func save(name: String, image: UIImage?) {
    if viewType == .update, let coffee = coffee {
      coffeeRepository.update(id: coffee.id, name: name)

      if let image = image, image != UIImage.randomCoffeeImage {
        imageManager.saveImage(type: .coffee, imageName: "coffee_\(coffee.id).jpg", image: image)
      } else {
        let previousImage = imageManager.loadImage(type: .coffee, imageName: "coffee_\(coffee.id).jpg")
        if previousImage != nil {
          imageManager.deleteImage(type: .coffee, imageName: "coffee_\(coffee.id).jpg")
        }
      }
    } else {
      let newCoffee = coffeeRepository.add(name: name)

      if let image = image, image != UIImage.randomCoffeeImage {
        imageManager.saveImage(type: .coffee, imageName: "coffee_\(newCoffee.id).jpg", image: image)
      }
    }
  }
}
