import UIKit

/// 화면 전환을 화면 자신에게서 떼어내기 위한 최소 규약.
/// 자식을 배열로 들고 있는 이유는 흐름이 끝날 때까지 참조를 유지할 곳이 필요해서다.
protocol Coordinator: AnyObject {
  var childCoordinators: [Coordinator] { get set }

  func start()
}

extension Coordinator {
  func addChild(_ coordinator: Coordinator) {
    childCoordinators.append(coordinator)
  }

  /// 흐름이 끝난 자식을 떼어낸다. 남겨두면 화면이 닫혀도 메모리에 계속 쌓인다.
  func removeChild(_ coordinator: Coordinator?) {
    guard let coordinator else { return }
    childCoordinators.removeAll { $0 === coordinator }
  }
}
