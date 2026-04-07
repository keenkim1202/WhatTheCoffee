import UIKit

final class AddCoffeeViewModel {

  enum ViewType {
    case add
    case update
  }

  // MARK: - Properties
  private let coffeeRepository: CoffeeRepositoryType
  private let imageManager = ImageManager.shared

  let viewType: ViewType
  let coffee: Coffee?

  // MARK: - Init
  init(coffeeRepository: CoffeeRepositoryType, coffee: Coffee? = nil) {
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
      return imageManager.loadImage(type: .coffee, imageName: "coffee_\(coffee._id).jpg") ?? UIImage.randomCoffeeImage
    }
    return UIImage.randomCoffeeImage
  }

  var currentName: String? {
    return coffee?.name
  }

  func save(name: String, image: UIImage?) {
    let item = Coffee(name: name)

    if viewType == .update, let coffee = coffee {
      coffeeRepository.update(item: coffee, new: item)

      if let image = image, image != UIImage.randomCoffeeImage {
        imageManager.saveImage(type: .coffee, imageName: "coffee_\(coffee._id).jpg", image: image)
      } else {
        let previousImage = imageManager.loadImage(type: .coffee, imageName: "coffee_\(coffee._id).jpg")
        if previousImage != nil {
          imageManager.deleteImage(type: .coffee, imageName: "coffee_\(coffee._id).jpg")
        }
      }
    } else {
      coffeeRepository.add(item: item)

      if let image = image, image != UIImage.randomCoffeeImage {
        imageManager.saveImage(type: .coffee, imageName: "coffee_\(item._id).jpg", image: image)
      }
    }
  }
}
