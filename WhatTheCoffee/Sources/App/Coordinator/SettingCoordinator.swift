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
    viewController.onExportRecords = { [weak self, weak viewController] in
      guard let self, let viewController else { return }
      exportRecords(from: viewController)
    }
    viewController.onFinish = { [weak self] in
      self?.onFinish?()
    }

    let navigation = UINavigationController(rootViewController: viewController)
    navigation.modalPresentationStyle = .fullScreen
    presenter.present(navigation, animated: true)
  }

  /// 기록과 사진을 묶어 공유 시트로 넘긴다.
  /// 만드는 데 시간이 걸려 끝날 때까지 다시 누르지 못하도록 화면을 잠근다.
  private func exportRecords(from presenter: UIViewController) {
    presenter.view.isUserInteractionEnabled = false

    container.makeExportRecordsUseCase().export { [weak presenter] result in
      guard let presenter else { return }
      presenter.view.isUserInteractionEnabled = true

      switch result {
      case .success(let url):
        let share = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        // 아이패드는 띄울 자리를 알려주지 않으면 크래시한다.
        share.popoverPresentationController?.sourceView = presenter.view
        share.popoverPresentationController?.sourceRect = CGRect(
          x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
        presenter.present(share, animated: true)

      case .failure(let error):
        let message = error is ExportRecordsUseCase.Failure
          ? "내보낼 기록이 아직 없어요."
          : "기록을 내보내지 못했어요.\n잠시 후 다시 시도해주세요."
        presenter.showErrorAlert(message)
      }
    }
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
