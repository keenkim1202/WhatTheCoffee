import UIKit
import AppTrackingTransparency
import FirebaseAnalytics

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  private var appCoordinator: AppCoordinator?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(windowScene: windowScene)
    let coordinator = AppCoordinator(window: window, container: DIContainer())
    coordinator.start()

    self.window = window
    self.appCoordinator = coordinator

    // 위젯을 눌러 실행된 경우 그 화면으로 바로 보낸다.
    if let url = connectionOptions.urlContexts.first?.url {
      coordinator.handle(url: url)
    }
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    appCoordinator?.handle(url: url)
  }

  func sceneDidDisconnect(_ scene: UIScene) {
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      ATTrackingManager.requestTrackingAuthorization { status in
        switch status {
        case .notDetermined, .restricted, .denied:
          Analytics.setAnalyticsCollectionEnabled(false)
        case .authorized:
          Analytics.setAnalyticsCollectionEnabled(true)
        @unknown default:
          Analytics.setAnalyticsCollectionEnabled(false)
        }
      }
    }
  }

  func sceneWillResignActive(_ scene: UIScene) {}
  func sceneWillEnterForeground(_ scene: UIScene) {}
  func sceneDidEnterBackground(_ scene: UIScene) {}
}
