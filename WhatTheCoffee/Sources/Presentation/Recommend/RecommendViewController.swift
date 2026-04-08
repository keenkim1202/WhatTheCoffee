import UIKit
import FirebaseAnalytics

class RecommendViewController: BaseViewController {

  // MARK: - Properties
  let viewModel: RecommendViewModel
  let container: DIContainer
  let buttonCornerRadius: CGFloat = 20

  // MARK: - UI
  private let todayCoffeeImage: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    iv.layer.cornerRadius = 5
    iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()

  private let todayCoffeeLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label.textColor = UIColor(named: "OrangeMainColor")
    label.textAlignment = .center
    label.numberOfLines = 3
    label.text = "오늘의 커피를 추천받아보세요!"
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var recommendButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("커피 추천 받기", for: .normal)
    button.setTitleColor(UIColor(named: "GreenSubColor"), for: .normal)
    button.titleLabel?.font = UIFont(name: "GowunBatang-Bold", size: 15)
    button.backgroundColor = UIColor.greenMainColor
    button.layer.cornerRadius = buttonCornerRadius
    button.tintColor = UIColor.greenMainColor
    button.addTarget(self, action: #selector(onRecommend), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let emptyView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(named: "AppearanceColor")
    view.isHidden = true
    view.translatesAutoresizingMaskIntoConstraints = false

    let label = UILabel()
    label.text = "커피 목록이 비어있어요 😭 추가해주세요 :)"
    label.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label.textColor = UIColor(named: "GreenSubColor")
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    return view
  }()

  // MARK: - Init
  init(viewModel: RecommendViewModel, container: DIContainer) {
    self.viewModel = viewModel
    self.container = container
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNav()
    configureLayout()
    bindViewModel()
    viewModel.fetchData()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Analytics.logEvent("TAB_recommend", parameters: nil)
    viewModel.fetchData()
  }

  // MARK: - Configure
  private func configureNav() {
    title = "Today's Coffee"
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(onInfo))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "커피 목록", style: .plain, target: self, action: #selector(onCoffeeList))
  }

  private func configureLayout() {
    view.backgroundColor = .systemBackground

    let innerStack = UIStackView(arrangedSubviews: [todayCoffeeImage, todayCoffeeLabel])
    innerStack.axis = .vertical
    innerStack.alignment = .center
    innerStack.spacing = 20
    innerStack.translatesAutoresizingMaskIntoConstraints = false

    let outerStack = UIStackView(arrangedSubviews: [innerStack, recommendButton])
    outerStack.axis = .vertical
    outerStack.alignment = .center
    outerStack.spacing = 69
    outerStack.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(outerStack)
    view.addSubview(emptyView)

    NSLayoutConstraint.activate([
      outerStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
      outerStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
      outerStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

      todayCoffeeImage.widthAnchor.constraint(equalTo: innerStack.widthAnchor),
      todayCoffeeImage.heightAnchor.constraint(equalTo: todayCoffeeImage.widthAnchor),

      todayCoffeeLabel.leadingAnchor.constraint(equalTo: innerStack.leadingAnchor),
      todayCoffeeLabel.trailingAnchor.constraint(equalTo: innerStack.trailingAnchor),

      recommendButton.leadingAnchor.constraint(equalTo: outerStack.leadingAnchor, constant: 30),
      recommendButton.trailingAnchor.constraint(equalTo: outerStack.trailingAnchor, constant: -30),
      recommendButton.widthAnchor.constraint(equalTo: recommendButton.heightAnchor, multiplier: 6),

      emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      emptyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      emptyView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }

  private func bindViewModel() {
    viewModel.onCoffeeListUpdated = { [weak self] in
      guard let self else { return }
      emptyView.isHidden = !viewModel.isEmpty
    }

    viewModel.onTodayCoffeeChanged = { [weak self] name, image in
      guard let self else { return }
      todayCoffeeLabel.text = name
      todayCoffeeImage.image = image
    }
  }

  // MARK: - Actions
  @objc private func onInfo() {
    let vc = SettingViewController(container: container)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    present(nav, animated: true)
  }

  @objc private func onCoffeeList() {
    let vc = CoffeeListViewController(viewModel: container.makeCoffeeListViewModel(), container: container)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    present(nav, animated: true)
  }

  @objc private func onRecommend() {
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
