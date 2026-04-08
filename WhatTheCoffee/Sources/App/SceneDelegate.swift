import UIKit
import AppTrackingTransparency
import FirebaseAnalytics

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  private let container = DIContainer.shared

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    let tabBar = UITabBarController()

    // 추천 탭
    let recommendVC = RecommendViewController(viewModel: container.makeRecommendViewModel(), container: container)
    recommendVC.checkIsFirst(coffeeRepository: container.coffeeRepository, cafeRepository: container.cafeRepository)
    let recommendNav = UINavigationController(rootViewController: recommendVC)
    recommendNav.tabBarItem = UITabBarItem(title: "추천", image: UIImage(systemName: "heart"), selectedImage: UIImage(systemName: "heart.fill"))

    // 근처 카페 탭
    let nearCafeVC = NearCafeViewController(viewModel: container.makeNearCafeViewModel(), container: container)
    let nearCafeNav = UINavigationController(rootViewController: nearCafeVC)
    nearCafeNav.tabBarItem = UITabBarItem(title: "근처 카페", image: UIImage(systemName: "mappin.circle"), selectedImage: UIImage(systemName: "mappin.circle.fill"))

    // 기록 탭
    let recordsVC = RecordsViewController(viewModel: container.makeRecordsViewModel(), container: container)
    let recordsNav = UINavigationController(rootViewController: recordsVC)
    recordsNav.tabBarItem = UITabBarItem(title: "기록", image: UIImage(systemName: "heart.text.square"), selectedImage: UIImage(systemName: "heart.text.square.fill"))

    // 통계 탭
    let statisticsVC = StatisticsViewController(viewModel: container.makeStatisticsViewModel())
    let statisticsNav = UINavigationController(rootViewController: statisticsVC)
    statisticsNav.tabBarItem = UITabBarItem(title: "통계", image: UIImage(systemName: "chart.bar"), selectedImage: UIImage(systemName: "chart.bar.fill"))

    tabBar.viewControllers = [recordsNav, recommendNav, nearCafeNav, statisticsNav]
    tabBar.selectedIndex = 1

    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = tabBar
    window.makeKeyAndVisible()
    self.window = window

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
