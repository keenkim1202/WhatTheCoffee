import UIKit

/// 추천 탭의 흐름. 설정과 커피 목록으로 이어진다.
final class RecommendCoordinator: Coordinator {

  var childCoordinators: [Coordinator] = []

  let navigationController: UINavigationController

  private let container: DIContainer
  private let rootViewController: RecommendViewController

  init(container: DIContainer) {
    self.container = container
    rootViewController = RecommendViewController(viewModel: container.makeRecommendViewModel())
    navigationController = UINavigationController(rootViewController: rootViewController)

    rootViewController.onShowSetting = { [weak self] in
      self?.showSetting()
    }
    rootViewController.onShowCoffeeList = { [weak self] in
      self?.showCoffeeList()
    }
  }

  func start() {
    navigationController.tabBarItem = UITabBarItem(
      title: "추천",
      image: UIImage(systemName: "heart"),
      selectedImage: UIImage(systemName: "heart.fill"))
  }

  private func showSetting() {
    let coordinator = SettingCoordinator(presenter: rootViewController, container: container)
    coordinator.onFinish = { [weak self, weak coordinator] in
      self?.removeChild(coordinator)
    }

    addChild(coordinator)
    coordinator.start()
  }

  /// 커피 목록은 자기 네비게이션 스택 위에서 추가·수정 화면을 쌓는다.
  /// 여기서만 push를 쓰는 이유는 목록과 상세가 한 흐름으로 이어지기 때문이다.
  private func showCoffeeList() {
    let viewController = CoffeeListViewController(viewModel: container.makeCoffeeListViewModel())
    let navigation = UINavigationController(rootViewController: viewController)
    navigation.modalPresentationStyle = .fullScreen

    viewController.onAddCoffee = { [weak self, weak navigation] in
      guard let self, let navigation else { return }
      pushCoffee(nil, on: navigation)
    }
    viewController.onSelectCoffee = { [weak self, weak navigation] coffee in
      guard let self, let navigation else { return }
      pushCoffee(coffee, on: navigation)
    }

    rootViewController.present(navigation, animated: true)
  }

  private func pushCoffee(_ coffee: CoffeeEntity?, on navigation: UINavigationController) {
    let viewController = AddCoffeeViewController(viewModel: container.makeAddCoffeeViewModel(coffee: coffee))
    navigation.pushViewController(viewController, animated: true)
  }
}
