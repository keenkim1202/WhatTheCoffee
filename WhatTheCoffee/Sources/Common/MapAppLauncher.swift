import UIKit

/// 기록한 좌표를 외부 지도 앱에서 열어준다.
/// 설치되지 않은 앱은 목록에 넣지 않는다. 애플 지도는 항상 열 수 있어 마지막 수단이 된다.
enum MapAppLauncher {

  struct Destination {
    let name: String
    let latitude: Double
    let longitude: Double
  }

  enum App: CaseIterable {
    case kakaoMap
    case naverMap
    case tmap
    case appleMaps

    var title: String {
      switch self {
      case .kakaoMap: return "카카오맵"
      case .naverMap: return "네이버 지도"
      case .tmap: return "티맵"
      case .appleMaps: return "지도"
      }
    }

    /// canOpenURL로 설치 여부를 물어보려면 Info.plist의 LSApplicationQueriesSchemes에 등록돼 있어야 한다.
    var probeURL: URL? {
      switch self {
      case .kakaoMap: return URL(string: "kakaomap://open")
      case .naverMap: return URL(string: "nmap://open")
      case .tmap: return URL(string: "tmap://open")
      case .appleMaps: return nil
      }
    }

    var isInstalled: Bool {
      guard let probeURL else { return true }
      return UIApplication.shared.canOpenURL(probeURL)
    }

    func url(for destination: Destination) -> URL? {
      let name = destination.name.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
      let lat = destination.latitude
      let lng = destination.longitude

      switch self {
      case .kakaoMap:
        return URL(string: "kakaomap://look?p=\(lat),\(lng)")
      case .naverMap:
        let appName = Bundle.main.bundleIdentifier ?? ""
        return URL(string: "nmap://place?lat=\(lat)&lng=\(lng)&name=\(name)&appname=\(appName)")
      case .tmap:
        // 티맵은 내비게이션 앱이라 목적지로 바로 설정한다. x가 경도, y가 위도다.
        return URL(string: "tmap://route?goalname=\(name)&goalx=\(lng)&goaly=\(lat)")
      case .appleMaps:
        return URL(string: "http://maps.apple.com/?ll=\(lat),\(lng)&q=\(name)")
      }
    }
  }

  static var available: [App] {
    return App.allCases.filter { $0.isInstalled }
  }

  static func open(_ app: App, to destination: Destination) {
    guard let url = app.url(for: destination) else { return }
    UIApplication.shared.open(url)
  }
}
