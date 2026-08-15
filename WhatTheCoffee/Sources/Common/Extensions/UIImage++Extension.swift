import UIKit

extension UIImage {
  static var randomCoffeeImage: UIImage {
    return UIImage(named: "random_coffee")!
  }
  
  static var defaultCafeImage: UIImage {
    return UIImage(named: "stamp_p_h")!
  }
  
  static var NearCafePlaceholder: UIImage {
    return UIImage(named: "cafeDefault3")!
  }

  /// 사각형 사진의 모서리를 깎아 스티커처럼 보이게 한다.
  ///
  /// 뷰에 cornerRadius를 주는 것으로는 부족하다.
  /// 커피 사진은 scaleAspectFit으로 그려져 뷰 안에서 여백을 두고 앉으므로,
  /// 뷰 경계를 깎아도 정작 이미지의 모서리는 그대로 뾰족하게 남는다.
  ///
  /// 배경을 지운 사진은 모서리가 이미 투명해 이 처리가 눈에 띄지 않는다.
  func roundedCorners(ratio: CGFloat = 0.14) -> UIImage {
    let rect = CGRect(origin: .zero, size: size)
    let radius = min(size.width, size.height) * ratio

    let format = UIGraphicsImageRendererFormat.default()
    format.opaque = false
    format.scale = scale

    return UIGraphicsImageRenderer(size: size, format: format).image { _ in
      UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
      draw(in: rect)
    }
  }
}
