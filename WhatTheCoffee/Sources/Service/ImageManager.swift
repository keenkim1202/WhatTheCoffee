import UIKit

enum DirectoryType: String {
  case coffee = "coffeeImages"
  case cafe = "cafeImages"
}

final class ImageManager {
  static let shared = ImageManager()
  private init() {}

  func saveImage(type: DirectoryType, imageName: String, image: UIImage) {
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    let filePath = documentDirectory.appendingPathComponent(type.rawValue)

    if !FileManager.default.fileExists(atPath: filePath.path) {
      do {
        try FileManager.default.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print("FAILED - fail to create directory: \(error)")
      }
    }

    let imageURL = filePath.appendingPathComponent(imageName)

    let data: Data?
    if type == .cafe {
      data = image.jpegData(compressionQuality: 0.5)
    } else {
      data = image.pngData()
    }

    guard let imageData = data else { return }

    if FileManager.default.fileExists(atPath: imageURL.path) {
      do {
        try FileManager.default.removeItem(at: imageURL)
      } catch {
        print("FAILED - fail to delete existing image: \(error)")
      }
    }

    do {
      try imageData.write(to: imageURL)
      print("SUCCESS - image saved.")
    } catch {
      print("FAILED - fail to save image: \(error)")
    }
  }

  func loadImage(type: DirectoryType, imageName: String) -> UIImage? {
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
    let filePath = documentDirectory.appendingPathComponent(type.rawValue)

    if !FileManager.default.fileExists(atPath: filePath.path) {
      do {
        try FileManager.default.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print("FAILED - fail to create directory: \(error)")
      }
    }

    let imageURL = filePath.appendingPathComponent(imageName)
    return UIImage(contentsOfFile: imageURL.path)
  }

  func deleteImage(type: DirectoryType, imageName: String) {
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    let filePath = documentDirectory.appendingPathComponent(type.rawValue)

    if !FileManager.default.fileExists(atPath: filePath.path) {
      do {
        try FileManager.default.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print("FAILED - fail to create directory: \(error)")
      }
    }

    let imageURL = filePath.appendingPathComponent(imageName)

    if FileManager.default.fileExists(atPath: imageURL.path) {
      do {
        try FileManager.default.removeItem(at: imageURL)
        print("REMOVE SUCCESS")
      } catch {
        print("FAILED - fail to delete image: \(error)")
      }
    }
  }
}
