import UIKit

final class ImageManager {
  static let shared = ImageManager()
  private init() {}

  /// 목록 셀과 추천 화면에 쓰기 충분한 크기. 원본 그대로 두면 사진 한 장이 10MB를 넘는다.
  private static let maxDimension: CGFloat = 1024

  func saveImage(type: DirectoryType, imageName: String, image: UIImage) {
    guard let imageURL = SharedImageStore.imageURL(type: type, imageName: imageName) else { return }

    // 줄이는 과정에서 알파 채널이 생기므로 판단은 원본으로 한다.
    // 아니면 배경이 꽉 찬 사진까지 전부 PNG가 되어 파일이 몇 배로 커진다.
    let isTransparent = hasAlpha(image)
    let resized = downscaled(image, opaque: !isTransparent)

    // 배경을 지운 이미지는 투명한 부분이 있어 JPEG로 저장하면 다 뭉개진다.
    // 반대로 배경이 꽉 찬 사진은 JPEG가 훨씬 작다.
    let data = isTransparent ? resized.pngData() : resized.jpegData(compressionQuality: 0.5)

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

  private func hasAlpha(_ image: UIImage) -> Bool {
    guard let alphaInfo = image.cgImage?.alphaInfo else { return false }
    switch alphaInfo {
    case .first, .last, .premultipliedFirst, .premultipliedLast:
      return true
    default:
      return false
    }
  }

  /// 긴 변을 기준으로 줄인다. 이미 작으면 그대로 둔다.
  /// UIImage.size는 포인트라 scale이 1보다 크면 실제 픽셀 수보다 작게 나온다.
  /// 저장되는 것은 픽셀이므로 CGImage의 픽셀 크기로 판단한다.
  private func downscaled(_ image: UIImage, opaque: Bool) -> UIImage {
    guard let cgImage = image.cgImage else { return image }

    let pixelWidth = CGFloat(cgImage.width)
    let pixelHeight = CGFloat(cgImage.height)
    let longestSide = max(pixelWidth, pixelHeight)
    guard longestSide > Self.maxDimension else { return image }

    let ratio = Self.maxDimension / longestSide
    let size = CGSize(width: pixelWidth * ratio, height: pixelHeight * ratio)

    let format = UIGraphicsImageRendererFormat.default()
    format.scale = 1
    format.opaque = opaque

    return UIGraphicsImageRenderer(size: size, format: format).image { _ in
      image.draw(in: CGRect(origin: .zero, size: size))
    }
  }

  /// maxPixelSize를 주면 그 크기로 줄여 읽는다.
  /// 목록 셀처럼 작게 보여줄 곳에서 원본을 펼치면 스크롤할 때마다 큰 비트맵을 만든다.
  func loadImage(type: DirectoryType, imageName: String, maxPixelSize: CGFloat? = nil) -> UIImage? {
    return SharedImageStore.load(type: type, imageName: imageName, maxPixelSize: maxPixelSize)
  }

  func deleteImage(type: DirectoryType, imageName: String) {
    guard let imageURL = SharedImageStore.imageURL(type: type, imageName: imageName) else { return }

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
