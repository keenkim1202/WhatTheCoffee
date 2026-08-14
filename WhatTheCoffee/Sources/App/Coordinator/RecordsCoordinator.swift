import UIKit

/// 기록 탭의 흐름.
/// 지금은 루트 화면을 만들고 딥링크 진입만 받는다. 화면 안의 전환은 아직 각 화면이 직접 한다.
final class RecordsCoordinator: Coordinator {

  var childCoordinators: [Coordinator] = []

  let navigationController: UINavigationController

  private let container: DIContainer
  private let rootViewController: RecordsViewController

  init(container: DIContainer) {
    self.container = container
    rootViewController = RecordsViewController(
      viewModel: container.makeRecordsViewModel(),
      container: container)
    navigationController = UINavigationController(rootViewController: rootViewController)
  }

  func start() {
    navigationController.tabBarItem = UITabBarItem(
      title: "기록",
      image: UIImage(systemName: "heart.text.square"),
      selectedImage: UIImage(systemName: "heart.text.square.fill"))
  }

  /// 위젯에서 바로 기록을 시작할 때.
  func showAddRecord() {
    rootViewController.presentAddRecord()
  }
}
