import UIKit

class PopupViewController: BaseViewController {

  // MARK: - Properties
  let cafe: NearCafeEntity

  // MARK: - UI
  private let backgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemBackground
    view.layer.cornerRadius = 8
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private lazy var closeButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("닫기", for: .normal)
    button.titleLabel?.font = UIFont(name: "GowunBatang-Bold", size: 15)
    button.backgroundColor = UIColor(named: "GreenMainColor")
    button.tintColor = UIColor(named: "DarkGreenColor")
    button.layer.cornerRadius = 8
    button.addTarget(self, action: #selector(onClose), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "GowunBatang-Bold", size: 17)
    label.textColor = UIColor(named: "OrangeMainColor")
    label.textAlignment = .center
    label.backgroundColor = UIColor(red: 1, green: 0.988, blue: 0.868, alpha: 1)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let detailAddressLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "GowunBatang-Bold", size: 16)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let addressLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.GowunBatang(type: .regular, size: 13)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let detailInfoTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "상세 정보"
    label.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var detailButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("상세 페이지로 이동", for: .normal)
    button.titleLabel?.font = UIFont(name: "GowunBatang-Bold", size: 15)
    button.backgroundColor = UIColor(named: "GreenSubColor")
    button.tintColor = UIColor(named: "GreenMainColor")
    button.layer.cornerRadius = 15
    button.addTarget(self, action: #selector(onDetailInfo), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  // MARK: - Init
  init(cafe: NearCafeEntity) {
    self.cafe = cafe
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureLayout()

    nameLabel.text = cafe.name
    addressLabel.text = cafe.address
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    if let touch = touches.first, touch.view == self.view {
      dismiss(animated: false)
    }
  }

  // MARK: - Configure
  private func configureLayout() {
    view.backgroundColor = UIColor(white: 0, alpha: 0.4)

    let infoStack = UIStackView(arrangedSubviews: [nameLabel, detailAddressLabel, addressLabel])
    infoStack.axis = .vertical
    infoStack.spacing = 10
    infoStack.translatesAutoresizingMaskIntoConstraints = false

    let detailStack = UIStackView(arrangedSubviews: [detailInfoTitleLabel, detailButton])
    detailStack.axis = .vertical
    detailStack.alignment = .leading
    detailStack.spacing = 10
    detailStack.translatesAutoresizingMaskIntoConstraints = false

    backgroundView.addSubview(closeButton)
    backgroundView.addSubview(infoStack)
    backgroundView.addSubview(detailStack)
    view.addSubview(backgroundView)

    NSLayoutConstraint.activate([
      backgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 48),
      backgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -49),
      backgroundView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
      backgroundView.widthAnchor.constraint(equalTo: backgroundView.heightAnchor, multiplier: 317.0 / 393.0),

      closeButton.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 15),
      closeButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -15),

      infoStack.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 80),
      infoStack.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
      infoStack.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),

      detailStack.topAnchor.constraint(equalTo: infoStack.bottomAnchor, constant: 30),
      detailStack.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
      detailStack.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),

      detailButton.leadingAnchor.constraint(equalTo: detailStack.leadingAnchor),
      detailButton.trailingAnchor.constraint(equalTo: detailStack.trailingAnchor),
      detailButton.heightAnchor.constraint(equalToConstant: 40)
    ])
  }

  // MARK: - Action
  @objc private func onClose() {
    dismiss(animated: false)
  }

  @objc private func onDetailInfo() {
    let vc = SettingDetailViewController(url: cafe.placeUrl)
    vc.title = cafe.name
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    present(nav, animated: true)
  }
}
