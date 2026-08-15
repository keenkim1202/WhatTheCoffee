import UIKit

/// 통계 탭의 흐름.
/// 차트와 목록에서 눌러 들어가는 곳은 모두 같은 화면이고 조건만 다르다.
final class StatisticsCoordinator: Coordinator {

  var childCoordinators: [Coordinator] = []

  let navigationController: UINavigationController

  private let container: DIContainer
  private let rootViewController: StatisticsViewController

  init(container: DIContainer) {
    self.container = container
    rootViewController = StatisticsViewController(viewModel: container.makeStatisticsViewModel())
    navigationController = UINavigationController(rootViewController: rootViewController)

    rootViewController.onSelectFilter = { [weak self] filter in
      self?.showRecords(matching: filter)
    }
  }

  func start() {
    navigationController.tabBarItem = UITabBarItem(
      title: "통계",
      image: UIImage(systemName: "chart.bar"),
      selectedImage: UIImage(systemName: "chart.bar.fill"))
  }

  private func showRecords(matching filter: RecordFilter) {
    let viewModel = FilteredRecordsViewModel(
      filter: filter,
      useCase: container.makeManageRecordsUseCase(),
      imageUseCase: container.makeManageImageUseCase())

    let viewController = FilteredRecordsViewController(viewModel: viewModel)
    viewController.onSelectRecord = { [weak self, weak viewController] cafe in
      guard let self, let viewController else { return }
      showRecord(cafe, from: viewController)
    }

    let navigation = UINavigationController(rootViewController: viewController)
    navigation.modalPresentationStyle = .fullScreen
    rootViewController.present(navigation, animated: true)
  }

  /// 목록에서 기록을 고르면 기록 탭과 같은 수정 화면으로 간다.
  private func showRecord(_ cafe: CafeEntity, from presenter: UIViewController) {
    let coordinator = AddRecordCoordinator(presenter: presenter, container: container, cafe: cafe)
    coordinator.onFinish = { [weak self, weak coordinator] in
      self?.removeChild(coordinator)
    }

    addChild(coordinator)
    coordinator.start()
  }
}
