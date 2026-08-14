import UIKit

/// 기록 탭의 흐름. 목록에서 열리는 지도·기록 추가·기록 수정·검색 결과를 맡는다.
final class RecordsCoordinator: Coordinator {

  var childCoordinators: [Coordinator] = []

  let navigationController: UINavigationController

  private let container: DIContainer
  private let rootViewController: RecordsViewController

  init(container: DIContainer) {
    self.container = container

    // 검색 결과 화면은 UISearchController가 들고 있어야 해서 목록보다 먼저 만든다.
    let searchResultsViewController = RecordSearchViewController(
      viewModel: container.makeRecordSearchViewModel())

    rootViewController = RecordsViewController(
      viewModel: container.makeRecordsViewModel(),
      searchResultsController: searchResultsViewController)
    navigationController = UINavigationController(rootViewController: rootViewController)

    rootViewController.onShowMap = { [weak self] in
      self?.showMap()
    }
    rootViewController.onAddRecord = { [weak self] in
      self?.showAddRecord()
    }
    rootViewController.onEditRecord = { [weak self] cafe in
      self?.showAddRecord(cafe: cafe)
    }
    // 검색 결과는 목록 위에 떠 있으므로 그 위에서 띄워야 가려지지 않는다.
    searchResultsViewController.onSelectCafe = { [weak self, weak searchResultsViewController] cafe in
      self?.showAddRecord(cafe: cafe, from: searchResultsViewController)
    }
  }

  func start() {
    navigationController.tabBarItem = UITabBarItem(
      title: "기록",
      image: UIImage(systemName: "heart.text.square"),
      selectedImage: UIImage(systemName: "heart.text.square.fill"))
  }

  /// 위젯에서 바로 기록을 시작할 때.
  func showAddRecord() {
    showAddRecord(cafe: nil, from: nil)
  }

  private func showAddRecord(cafe: CafeEntity?, from presenter: UIViewController? = nil) {
    let coordinator = AddRecordCoordinator(
      presenter: presenter ?? rootViewController,
      container: container,
      cafe: cafe)
    coordinator.onFinish = { [weak self, weak coordinator] in
      self?.removeChild(coordinator)
    }

    addChild(coordinator)
    coordinator.start()
  }

  private func showMap() {
    let viewController = RecordMapViewController(
      viewModel: container.makeRecordsViewModel(),
      checkClosedUseCase: container.makeCheckClosedCafeUseCase())

    let navigation = UINavigationController(rootViewController: viewController)
    navigation.modalPresentationStyle = .fullScreen
    rootViewController.present(navigation, animated: true)
  }
}
