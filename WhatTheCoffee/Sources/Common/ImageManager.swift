import UIKit

enum DirectoryType: String {
  case coffee = "coffeeImages"
  case cafe = "cafeImages"
}

final class ImageManager {
  static let shared = ImageManager()
  private init() {}

  /// 목록 셀과 추천 화면에 쓰기 충분한 크기. 원본 그대로 두면 사진 한 장이 10MB를 넘는다.
  private static let maxDimension: CGFloat = 1024

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

    let resized = downscaled(image)

    let data: Data?
    if type == .cafe {
      data = resized.jpegData(compressionQuality: 0.5)
    } else {
      // 커피는 누끼의 투명 배경을 살려야 해서 PNG로 둔다.
      data = resized.pngData()
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

  /// 긴 변을 기준으로 줄인다. 이미 작으면 그대로 둔다.
  /// UIImage.size는 포인트라 scale이 1보다 크면 실제 픽셀 수보다 작게 나온다.
  /// 저장되는 것은 픽셀이므로 CGImage의 픽셀 크기로 판단한다.
  private func downscaled(_ image: UIImage) -> UIImage {
    guard let cgImage = image.cgImage else { return image }

    let pixelWidth = CGFloat(cgImage.width)
    let pixelHeight = CGFloat(cgImage.height)
    let longestSide = max(pixelWidth, pixelHeight)
    guard longestSide > Self.maxDimension else { return image }

    let ratio = Self.maxDimension / longestSide
    let size = CGSize(width: pixelWidth * ratio, height: pixelHeight * ratio)

    let format = UIGraphicsImageRendererFormat.default()
    format.scale = 1
    format.opaque = false

    return UIGraphicsImageRenderer(size: size, format: format).image { _ in
      image.draw(in: CGRect(origin: .zero, size: size))
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
