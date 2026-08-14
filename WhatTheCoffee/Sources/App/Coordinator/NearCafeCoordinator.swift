import UIKit
import CoreLocation

/// 근처 카페 탭의 흐름. 목록에서 상세·지도로 가고, 상세에서 기록 추가와 가게 정보로 이어진다.
final class NearCafeCoordinator: Coordinator {

  var childCoordinators: [Coordinator] = []

  let navigationController: UINavigationController

  private let container: DIContainer
  private let rootViewController: NearCafeViewController

  init(container: DIContainer) {
    self.container = container
    rootViewController = NearCafeViewController(viewModel: container.makeNearCafeViewModel())
    navigationController = UINavigationController(rootViewController: rootViewController)

    rootViewController.onSelectCafe = { [weak self] cafe in
      self?.showDetail(cafe)
    }
    rootViewController.onShowCafeMap = { [weak self] cafes, myLocation in
      self?.showCafeMap(cafes: cafes, myLocation: myLocation)
    }
  }

  func start() {
    navigationController.tabBarItem = UITabBarItem(
      title: "근처 카페",
      image: UIImage(systemName: "mappin.circle"),
      selectedImage: UIImage(systemName: "mappin.circle.fill"))
  }

  // MARK: - Detail
  private func showDetail(_ cafe: NearCafeEntity) {
    let viewController = DetailNearCafeViewController(nearCafe: cafe)

    viewController.onStartRecord = { [weak self, weak viewController] location in
      guard let self, let viewController else { return }
      showAddRecord(prefilledLocation: location, from: viewController)
    }
    viewController.onShowPlaceInfo = { [weak self, weak viewController] in
      guard let self, let viewController else { return }
      showPlaceInfo(of: cafe, from: viewController)
    }

    let navigation = UINavigationController(rootViewController: viewController)
    navigation.title = cafe.name
    navigation.modalPresentationStyle = .fullScreen
    rootViewController.present(navigation, animated: true)
  }

  /// 기록 추가는 기록 탭과 같은 흐름이라 그대로 가져다 쓴다.
  private func showAddRecord(prefilledLocation: SelectedLocation, from presenter: UIViewController) {
    let coordinator = AddRecordCoordinator(
      presenter: presenter,
      container: container,
      prefilledLocation: prefilledLocation)
    coordinator.onFinish = { [weak self, weak coordinator] in
      self?.removeChild(coordinator)
    }

    addChild(coordinator)
    coordinator.start()
  }

  // MARK: - Map
  private func showCafeMap(cafes: [NearCafeEntity], myLocation: CLLocationCoordinate2D?) {
    let viewController = CafeLocationViewController(nearCafeLists: cafes, myLocation: myLocation)
    viewController.onSelectCafe = { [weak self, weak viewController] cafe in
      guard let self, let viewController else { return }
      showPopup(for: cafe, from: viewController)
    }

    let navigation = UINavigationController(rootViewController: viewController)
    navigation.modalPresentationStyle = .fullScreen
    rootViewController.present(navigation, animated: true)
  }

  /// 지도 위 핀을 눌렀을 때 뜨는 미리보기. 뒤 지도가 보여야 해서 애니메이션 없이 덮는다.
  private func showPopup(for cafe: NearCafeEntity, from presenter: UIViewController) {
    let viewController = PopupViewController(cafe: cafe)
    viewController.modalPresentationStyle = .overFullScreen
    viewController.onShowPlaceInfo = { [weak self, weak viewController] in
      guard let self, let viewController else { return }
      showPlaceInfo(of: cafe, from: viewController)
    }

    presenter.present(viewController, animated: false)
  }

  // MARK: - Place Info
  /// 카카오 장소 페이지를 웹뷰로 연다. 상세와 지도 팝업 양쪽에서 같은 화면을 쓴다.
  private func showPlaceInfo(of cafe: NearCafeEntity, from presenter: UIViewController) {
    let viewController = SettingDetailViewController(url: cafe.placeUrl)
    viewController.title = cafe.name

    let navigation = UINavigationController(rootViewController: viewController)
    navigation.modalPresentationStyle = .fullScreen
    presenter.present(navigation, animated: true)
  }
}
