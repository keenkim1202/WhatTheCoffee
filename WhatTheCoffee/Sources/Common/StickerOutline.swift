import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

/// 스티커처럼 보이도록 이미지 모양을 따라 흰 테두리를 그린다.
/// 피사체 고르기와 커피 고르기가 같은 방식으로 선택을 표시한다.
/// 알파 채널을 부풀려 실루엣을 만들고 색을 채운 뒤 원본을 그 위에 얹는다.
/// iOS 스티커의 흰 테두리와 같은 방식이다.
enum StickerOutline {
  private static let context = CIContext()

  /// 셀에 보이는 크기. 원본 해상도 그대로 처리하면 느린 데다,
  /// 고정 반경으로 부풀려봐야 4000픽셀짜리에서는 1포인트도 안 되어 선이 보이지 않는다.
  private static let renderSize: CGFloat = 240
  private static let outlineRadius: CGFloat = 10

  static func outlined(_ image: UIImage, color: UIColor) -> UIImage? {
    // 다시 그리는 과정에서 UIImage가 들고 있던 회전도 함께 반영된다.
    guard let scaled = downscaled(image), let cgImage = scaled.cgImage else { return nil }

    let source = CIImage(cgImage: cgImage)
    let dilated = source.applyingFilter(
      "CIMorphologyMaximum", parameters: [kCIInputRadiusKey: outlineRadius])

    let silhouette = CIImage(color: CIColor(color: color))
      .cropped(to: dilated.extent)
      .applyingFilter("CIBlendWithAlphaMask", parameters: [kCIInputMaskImageKey: dilated])

    let composited = source.composited(over: silhouette)
    guard let output = context.createCGImage(composited, from: composited.extent) else { return nil }
    return UIImage(cgImage: output)
  }

  private static func downscaled(_ image: UIImage) -> UIImage? {
    guard image.cgImage != nil else { return nil }

    // CGImage의 픽셀 크기는 회전 전 기준이라 세로 사진이면 가로세로가 뒤바뀐다.
    // 그 크기로 그리면 이미지가 눌린 채로 들어간다. 회전이 반영된 size를 쓴다.
    let longestSide = max(image.size.width, image.size.height)
    let ratio = min(1, renderSize / longestSide)
    let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)

    let format = UIGraphicsImageRendererFormat.default()
    format.scale = 1
    format.opaque = false

    return UIGraphicsImageRenderer(size: size, format: format).image { _ in
      image.draw(in: CGRect(origin: .zero, size: size))
    }
  }
}
