import UIKit

extension UIFont {
  class func GowunBatang(type: GowunBatangType, size: CGFloat) -> UIFont! {
    guard let font = UIFont(name: type.name, size: size) else { return nil }
    return font
  }
  
  public enum GowunBatangType {
    case regular
    case bold
    
    var name: String {
      switch self {
      case .regular: return "GowunBatang-Bold"
      case .bold:    return "GowunBatang-Regular"
      }
    }
  }
}
