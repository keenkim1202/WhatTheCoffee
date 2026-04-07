import UIKit
import FirebaseAnalytics

class RecommendViewController: BaseViewController {

  // MARK: - Properties
  var viewModel: RecommendViewModel!
  var environment: Environment? = nil
  let buttonCornerRadius: CGFloat = 20

  // MARK: - UI
  @IBOutlet weak var todayCoffeeImage: UIImageView!
  @IBOutlet weak var todayCoffeeLabel: UILabel!
  @IBOutlet weak var recommendButton: UIButton!
  @IBOutlet weak var emptyView: UIView!

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    configure()
    bindViewModel()
    viewModel.fetchData()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Analytics.logEvent("TAB_recommend", parameters: nil)
    viewModel.fetchData()
  }

  // MARK: - Configure
  func configure() {
    todayCoffeeImage.layer.cornerRadius = CGFloat(5)
    recommendButton.layer.cornerRadius = buttonCornerRadius
    recommendButton.tintColor = UIColor.greenMainColor
    recommendButton.titleLabel?.textColor = UIColor.oppositeColor
  }

  func bindViewModel() {
    viewModel.onCoffeeListUpdated = { [weak self] in
      guard let self = self else { return }
      self.emptyView.isHidden = !self.viewModel.isEmpty
    }

    viewModel.onTodayCoffeeChanged = { [weak self] name, image in
      guard let self = self else { return }
      self.todayCoffeeLabel.text = name
      self.todayCoffeeImage.image = image
    }
  }

  // MARK: - Actions
  @IBAction func onInfo(_ sender: UIBarButtonItem) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "settingVC") as! SettingViewController
    guard let env = environment else { return }
    vc.environment = env

    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    self.present(nav, animated: true)
  }

  @IBAction func onCoffeeList(_ sender: UIBarButtonItem) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "coffeeListVC") as! CoffeeListViewController
    guard let env = environment else { return }
    vc.viewModel = CoffeeListViewModel(coffeeRepository: env.coffeeRepository)
    vc.environment = env

    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    self.present(nav, animated: true)
  }

  @IBAction func onRecommend(_ sender: UIButton) {
    recommendButton.setTitle("다시 추천 받기", for: .normal)

    if let result = viewModel.recommend() {
      todayCoffeeImage.image = result.image
      todayCoffeeLabel.text = result.name
      todayCoffeeLabel.font = UIFont.GowunBatang(type: .regular, size: 15)
    } else {
      showErrorAlert("커피 리스트가 비어있습니다.\n커피 목록에서 추가해주세요!")
    }
  }
}
