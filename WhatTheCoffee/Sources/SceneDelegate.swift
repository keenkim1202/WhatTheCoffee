import UIKit
import AppTrackingTransparency
import FirebaseAnalytics
import RealmSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  var environment: Environment? = nil

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = (scene as? UIWindowScene) else { return }
    guard let window = scene.windows.first else { return }
    guard let tabBar = window.rootViewController as? UITabBarController else { return }
    guard let viewControllers = tabBar.viewControllers else { return }

    let realm = try! Realm()
    let dataSource = RealmDataSource(realm: realm)
    environment = AppEnvironment(coffeeRepository: CoffeeRepositoryImpl(dataSource: dataSource), cafeRepository: CafeRepositoryImpl(dataSource: dataSource))

    for vc in viewControllers {
      switch vc.children.first {
      case let vc as RecommendViewController:
        guard let env = environment else { break }
        vc.environment = env
        vc.viewModel = RecommendViewModel(coffeeRepository: env.coffeeRepository)
        vc.checkIsFirst(env: env)

      case let vc as NearCafeViewController:
        vc.environment = environment

      case let vc as RecordsViewController:
        guard let env = environment else { break }
        vc.environment = env
        vc.viewModel = RecordsViewModel(cafeRepository: env.cafeRepository)

      default:
        break
      }
    }

    let settingVC = SettingViewController()
    settingVC.environment = environment

    sleep(1)
  }

  func sceneDidDisconnect(_ scene: UIScene) {
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      // ATT Framework
      ATTrackingManager.requestTrackingAuthorization { status in
        switch status {
        case .notDetermined:
          print("Not Determined")
          Analytics.setAnalyticsCollectionEnabled(false)
        case .restricted:
          print("restricted")
          Analytics.setAnalyticsCollectionEnabled(false)
        case .denied:
          print("denied")
          Analytics.setAnalyticsCollectionEnabled(false)
        case .authorized:
          print("authorized")
          Analytics.setAnalyticsCollectionEnabled(true)
        @unknown default:
          print("unknown")
          Analytics.setAnalyticsCollectionEnabled(false)
        }
      }
    }
  }

  func sceneWillResignActive(_ scene: UIScene) {
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
  }

}
