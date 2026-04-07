import UIKit

// MARK: - Document Data Manage (UIViewController convenience wrapper)
extension UIViewController {

  // MARK: - Save Document
  func saveImageToDocumentDirectory(type: DirectoryType, imageName: String, image: UIImage) {
    ImageManager.shared.saveImage(type: type, imageName: imageName, image: image)
  }

  // MARK: - Load Document
  func loadImageFromDocumentDirectory(type: DirectoryType, imageName: String) -> UIImage? {
    return ImageManager.shared.loadImage(type: type, imageName: imageName)
  }

  // MARK: - Remove Document
  func deleteImageFromDucumentDirectory(type: DirectoryType, imageName: String) {
    ImageManager.shared.deleteImage(type: type, imageName: imageName)
  }

}
