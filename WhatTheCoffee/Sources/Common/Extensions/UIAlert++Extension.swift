import UIKit

extension UIAlertController {
  enum ContentType: String {
    case error = "⚠️ 오류 🤯"
    case success = "✅"
  }
  
  /// 확인 버튼 하나로 닫는 알림.
  static func show(_ presentedHost: UIViewController,
                   contentType: ContentType,
                   message: String) {
    let alert = UIAlertController(
      title: contentType.rawValue,
      message: message,
      preferredStyle: .alert)
    let okAction = UIAlertAction(
      title: "확인", style: .default, handler: nil)
    alert.addAction(okAction)
    presentedHost.present(alert, animated: true)
  }
  
  /// 네/아니오를 묻는 알림. 되돌릴 수 없는 동작에 쓰므로 '네'가 destructive다.
  static func confirm(_ presentedHost: UIViewController,
                      title: String,
                      message: String,
                      onConfirm: @escaping () -> Void) {
    let alert = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert)
    let no = UIAlertAction(
      title: "아니오", style: .default, handler: nil)
    let yes = UIAlertAction(
      title: "네", style: .destructive) { _ in onConfirm() }
    alert.addAction(no)
    alert.addAction(yes)
    presentedHost.present(alert, animated: true)
  }
}
