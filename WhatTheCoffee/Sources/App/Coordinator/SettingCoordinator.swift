import UIKit

/// 설정 흐름. 추천 화면에서 모달로 열린다.
final class SettingCoordinator: Coordinator {

  var childCoordinators: [Coordinator] = []

  var onFinish: (() -> Void)?

  private let presenter: UIViewController
  private let container: DIContainer
  private weak var rootViewController: SettingViewController?

  init(presenter: UIViewController, container: DIContainer) {
    self.presenter = presenter
    self.container = container
  }

  func start() {
    let viewController = SettingViewController(defaultDataUseCase: container.makeManageDefaultDataUseCase())
    rootViewController = viewController

    viewController.onShowDefaultImages = { [weak self, weak viewController] title in
      guard let self, let viewController else { return }
      showDefaultImages(title: title, from: viewController)
    }
    viewController.onShowDetail = { [weak self, weak viewController] index, title in
      guard let self, let viewController else { return }
      showDetail(index: index, title: title, from: viewController)
    }
    viewController.onFinish = { [weak self] in
      self?.onFinish?()
    }

    let navigation = UINavigationController(rootViewController: viewController)
    navigation.modalPresentationStyle = .fullScreen
    presenter.present(navigation, animated: true)
  }

  private func showDefaultImages(title: String, from presenter: UIViewController) {
    let viewController = AddDefaultImageViewController(
      defaultDataUseCase: container.makeManageDefaultDataUseCase())
    viewController.title = title

    let navigation = UINavigationController(rootViewController: viewController)
    navigation.modalPresentationStyle = .fullScreen
    presenter.present(navigation, animated: true)
  }

  private func showDetail(index: Int, title: String, from presenter: UIViewController) {
    let viewController = SettingDetailViewController(index: index)
    viewController.title = title

    let navigation = UINavigationController(rootViewController: viewController)
    navigation.modalPresentationStyle = .fullScreen
    presenter.present(navigation, animated: true)
  }
}
