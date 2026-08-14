import UIKit

/// 앱의 조립이 시작되는 한 곳.
/// 탭 구성과 위젯 딥링크 처리를 맡고, 화면은 각 탭의 Coordinator에게 넘긴다.
final class AppCoordinator: Coordinator {

  var childCoordinators: [Coordinator] = []

  private let window: UIWindow
  private let container: DIContainer
  private let tabBarController = UITabBarController()

  /// 딥링크가 기록 화면을 직접 열어야 해서 따로 들고 있는다.
  private var recordsCoordinator: RecordsCoordinator?

  init(window: UIWindow, container: DIContainer) {
    self.window = window
    self.container = container
  }

  func start() {
    let records = RecordsCoordinator(container: container)
    records.start()
    addChild(records)
    recordsCoordinator = records

    tabBarController.viewControllers = [
      records.navigationController,
      makeRecommendTab(),
      makeNearCafeTab(),
      makeStatisticsTab()
    ]
    tabBarController.selectedIndex = Self.defaultTabIndex

    window.rootViewController = tabBarController
    window.makeKeyAndVisible()
  }

  // MARK: - Deep Link
  /// 위젯에서 넘어온 주소를 받아 해당 화면으로 보낸다.
  /// 탭 순서나 화면 타입을 밖에서 알 필요가 없도록 여기서만 처리한다.
  func handle(url: URL) {
    guard let route = WidgetRoute(url: url) else { return }
    handle(route: route)
  }

  func handle(route: WidgetRoute) {
    guard let index = route.tabIndex else { return }
    tabBarController.selectedIndex = index

    guard route == .addRecord else { return }
    recordsCoordinator?.showAddRecord()
  }

  // MARK: - Tabs
  /// 아직 Coordinator로 옮기지 않은 탭들. 순서대로 이관한다.
  private func makeRecommendTab() -> UIViewController {
    let vc = RecommendViewController(viewModel: container.makeRecommendViewModel(), container: container)
    vc.checkIsFirst(coffeeRepository: container.coffeeRepository, cafeRepository: container.cafeRepository)

    let navigation = UINavigationController(rootViewController: vc)
    navigation.tabBarItem = UITabBarItem(
      title: "추천",
      image: UIImage(systemName: "heart"),
      selectedImage: UIImage(systemName: "heart.fill"))
    return navigation
  }

  private func makeNearCafeTab() -> UIViewController {
    let vc = NearCafeViewController(viewModel: container.makeNearCafeViewModel(), container: container)

    let navigation = UINavigationController(rootViewController: vc)
    navigation.tabBarItem = UITabBarItem(
      title: "근처 카페",
      image: UIImage(systemName: "mappin.circle"),
      selectedImage: UIImage(systemName: "mappin.circle.fill"))
    return navigation
  }

  private func makeStatisticsTab() -> UIViewController {
    let vc = StatisticsViewController(viewModel: container.makeStatisticsViewModel())

    let navigation = UINavigationController(rootViewController: vc)
    navigation.tabBarItem = UITabBarItem(
      title: "통계",
      image: UIImage(systemName: "chart.bar"),
      selectedImage: UIImage(systemName: "chart.bar.fill"))
    return navigation
  }

  /// 처음 보이는 탭은 추천이다. WidgetRoute.tabIndex와 같은 배열 순서를 따른다.
  private static let defaultTabIndex = 1
}
