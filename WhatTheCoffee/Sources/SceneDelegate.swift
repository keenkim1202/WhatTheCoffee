import UIKit
import AppTrackingTransparency
import FirebaseAnalytics

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  private let container = DIContainer.shared

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = (scene as? UIWindowScene) else { return }
    guard let window = scene.windows.first else { return }
    guard let tabBar = window.rootViewController as? UITabBarController else { return }
    guard let viewControllers = tabBar.viewControllers else { return }

    for vc in viewControllers {
      switch vc.children.first {
      case let vc as RecommendViewController:
        vc.container = container
        vc.viewModel = container.makeRecommendViewModel()
        vc.checkIsFirst(coffeeRepository: container.coffeeRepository, cafeRepository: container.cafeRepository)

      case let vc as NearCafeViewController:
        vc.container = container
        vc.viewModel = container.makeNearCafeViewModel()

      case let vc as RecordsViewController:
        vc.container = container
        vc.viewModel = container.makeRecordsViewModel()

      default:
        break
      }
    }

    sleep(1)
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
