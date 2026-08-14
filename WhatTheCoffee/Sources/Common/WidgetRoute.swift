import Foundation

/// 위젯이 앱의 어느 화면을 열지 가리키는 주소.
/// 위젯과 앱이 같은 정의를 봐야 해서 두 타깃에서 함께 컴파일한다.
enum WidgetRoute: String {
  case records
  case statistics
  case addRecord

  private static let scheme = "whatthecoffee"

  var url: URL? {
    return URL(string: "\(Self.scheme)://\(rawValue)")
  }

  init?(url: URL) {
    guard url.scheme == Self.scheme else { return nil }
    // whatthecoffee://records 형태라 host에 이름이 들어온다.
    guard let host = url.host, let route = WidgetRoute(rawValue: host) else { return nil }
    self = route
  }

  /// 탭 순서와 맞춰야 한다. SceneDelegate의 viewControllers 배열 기준.
  var tabIndex: Int? {
    switch self {
    case .records, .addRecord: return 0
    case .statistics: return 3
    }
  }
}
