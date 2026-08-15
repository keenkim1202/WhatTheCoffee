import UIKit

/// 기록을 추가하거나 고치는 흐름.
/// 기록 목록, 검색 결과, 근처 카페 상세 세 곳에서 열리기 때문에 어느 탭에도 두지 않고 따로 뺐다.
final class AddRecordCoordinator: Coordinator {

  var childCoordinators: [Coordinator] = []

  /// 흐름이 끝났음을 부모에게 알린다. 알리지 않으면 부모가 자식을 계속 붙들고 있는다.
  var onFinish: (() -> Void)?

  private let presenter: UIViewController
  private let container: DIContainer
  private let cafe: CafeEntity?
  private let prefilledLocation: SelectedLocation?

  init(presenter: UIViewController,
       container: DIContainer,
       cafe: CafeEntity? = nil,
       prefilledLocation: SelectedLocation? = nil) {
    self.presenter = presenter
    self.container = container
    self.cafe = cafe
    self.prefilledLocation = prefilledLocation
  }

  func start() {
    let viewModel = container.makeAddRecordViewModel(cafe: cafe, prefilledLocation: prefilledLocation)
    let viewController = AddRecordViewController(viewModel: viewModel)

    viewController.onSearchCafe = { [weak self, weak viewController] in
      guard let self, let viewController else { return }
      showCafeSearch(from: viewController)
    }
    viewController.onPickCoffee = { [weak self, weak viewController] in
      guard let self, let viewController else { return }
      showCoffeePicker(from: viewController)
    }
    viewController.onFinish = { [weak self] in
      self?.onFinish?()
    }

    presenter.present(viewController, animated: true)
  }

  /// 커피 목록에서 무엇을 마셨는지 고른다.
  /// 목록은 추천 탭이 들고 있는 것과 같아서, 두 화면이 같은 커피를 가리키게 된다.
  private func showCoffeePicker(from viewController: AddRecordViewController) {
    let names = container.makeManageCoffeeListUseCase().fetchAll().map { $0.name }
    let picker = CoffeePickerViewController(
      coffeeNames: names,
      selectedName: viewController.selectedCoffeeName)

    picker.onSelect = { [weak viewController] name in
      viewController?.applyCoffee(name)
    }

    if let sheet = picker.sheetPresentationController {
      sheet.detents = [.medium(), .large()]
      sheet.prefersGrabberVisible = true
    }
    viewController.present(picker, animated: true)
  }

  /// 카페 이름을 검색해 위치를 채우는 시트.
  /// 고른 결과는 화면이 직접 받아야 해서 delegate는 그대로 두고, 띄우는 일만 가져왔다.
  private func showCafeSearch(from viewController: AddRecordViewController) {
    let searchViewController = CafeSearchBottomSheetViewController()
    searchViewController.delegate = viewController
    searchViewController.initialQuery = viewController.searchQuery

    searchViewController.onShowCafeDetail = { [weak searchViewController] cafe, confirm in
      guard let searchViewController else { return }
      let detail = CafeSearchDetailViewController()
      detail.nearCafe = cafe
      detail.onSelect = confirm

      let navigation = UINavigationController(rootViewController: detail)
      navigation.modalPresentationStyle = .fullScreen
      searchViewController.present(navigation, animated: true)
    }

    if let sheet = searchViewController.sheetPresentationController {
      sheet.detents = [.medium(), .large()]
      sheet.prefersGrabberVisible = true
    }

    viewController.present(searchViewController, animated: true)
  }
}
