import UIKit

final class ManageImageUseCase {
  private let imageManager: ImageManager

  init(imageManager: ImageManager = .shared) {
    self.imageManager = imageManager
  }

  func loadCoffeeImage(id: String) -> UIImage? {
    imageManager.loadImage(type: .coffee, imageName: "coffee_\(id).jpg")
  }

  func saveCoffeeImage(id: String, image: UIImage) {
    imageManager.saveImage(type: .coffee, imageName: "coffee_\(id).jpg", image: image)
  }

  func deleteCoffeeImage(id: String) {
    imageManager.deleteImage(type: .coffee, imageName: "coffee_\(id).jpg")
  }

  func loadCafeImage(id: String) -> UIImage? {
    imageManager.loadImage(type: .cafe, imageName: "cafe_\(id).jpg")
  }

  func saveCafeImage(id: String, image: UIImage) {
    imageManager.saveImage(type: .cafe, imageName: "cafe_\(id).jpg", image: image)
  }

  func deleteCafeImage(id: String) {
    imageManager.deleteImage(type: .cafe, imageName: "cafe_\(id).jpg")
  }
}
