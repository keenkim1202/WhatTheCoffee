import UIKit

class BaseViewController: UIViewController {
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    adjustNavigationBarFont()
  }

  /// 바 버튼은 viewDidLoad 뒤에 만들어지는 화면도 있어 표시 직전에 한 번 더 훑는다.
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    NavigationBarAppearance.hideSharedBackground(on: navigationItem.leftBarButtonItems)
    NavigationBarAppearance.hideSharedBackground(on: navigationItem.rightBarButtonItems)
  }
}
