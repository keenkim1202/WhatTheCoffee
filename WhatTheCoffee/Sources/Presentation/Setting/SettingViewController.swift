import UIKit

class SettingViewController: BaseViewController {

  // MARK: - Properties
  private let defaultDataUseCase: ManageDefaultDataUseCase

  /// 화면 전환은 Coordinator가 맡는다.
  var onShowDefaultImages: ((String) -> Void)?
  var onExportRecords: (() -> Void)?
  var onShowDetail: ((Int, String) -> Void)?
  var onFinish: (() -> Void)?
  let settingList: [String] = ["🧞‍♂️ 문의하기", "📝 개인정보 처리방침","📚 오픈소스 라이선스", "🧊 아이스 커피 이미지 불러오기", "☕️ 핫 커피 이미지 불러오기", "☝️ 개별 이미지 추가하기", "💾 기록 내보내기"]

  // MARK: - UI
  private let tableView: UITableView = {
    let tv = UITableView(frame: .zero, style: .insetGrouped)
    tv.separatorStyle = .none
    tv.sectionHeaderHeight = 18
    tv.sectionFooterHeight = 18
    tv.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
    tv.translatesAutoresizingMaskIntoConstraints = false
    return tv
  }()

  private let versionLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 15, weight: .medium)
    label.textColor = UIColor(white: 0.667, alpha: 1)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let versionContainer: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(named: "VersionBackgroundColor")
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private let bottomFillView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(named: "VersionBackgroundColor")
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  // MARK: - Init
  init(defaultDataUseCase: ManageDefaultDataUseCase) {
    self.defaultDataUseCase = defaultDataUseCase
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
    configure()
  }

  // MARK: - Configure
  private func configure() {
    tableView.delegate = self
    tableView.dataSource = self
    versionLabel.text = versionInfo()
  }

  private func configureNav() {
    title = "설정"
    adjustNavigationBarFont()
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(onClose))
  }

  private func configureLayout() {
    view.backgroundColor = UIColor(named: "AppearanceColor")

    versionContainer.addSubview(versionLabel)
    view.addSubview(tableView)
    view.addSubview(versionContainer)
    view.addSubview(bottomFillView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),

      versionContainer.topAnchor.constraint(equalTo: tableView.bottomAnchor),
      versionContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      versionContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      versionContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      versionContainer.heightAnchor.constraint(equalToConstant: 40),

      versionLabel.leadingAnchor.constraint(equalTo: versionContainer.leadingAnchor, constant: 20),
      versionLabel.trailingAnchor.constraint(equalTo: versionContainer.trailingAnchor, constant: -20),
      versionLabel.centerYAnchor.constraint(equalTo: versionContainer.centerYAnchor),

      bottomFillView.topAnchor.constraint(equalTo: versionContainer.bottomAnchor),
      bottomFillView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      bottomFillView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      bottomFillView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  private func versionInfo() -> String {
    guard
      let dictionary = Bundle.main.infoDictionary,
      let version = dictionary["CFBundleShortVersionString"] as? String
    else { return "" }
    return "v \(version)"
  }

  // MARK: - Action
  @objc private func onClose() {
    dismiss(animated: true) { [weak self] in
      self?.onFinish?()
    }
  }
}

// MARK: - TableViewDelegate
extension SettingViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    if indexPath.section == 3 {
      addAlert("🧊 아이스 커피 재추가", "커피목록에 존재여부와 관계없이\n 기존 이미지 모두 추가됩니다.") {
        self.defaultDataUseCase.addDefaultIceCoffees()
        self.showSuccessAlert("재추가에 성공하였습니다.")
      }
    } else if indexPath.section == 4 {
      addAlert("☕️ 핫 커피 재추가", "커피목록에 존재여부와 관계없이\n 기존 이미지 모두 추가됩니다.") {
        self.defaultDataUseCase.addDefaultHotCoffees()
        self.showSuccessAlert("재추가에 성공하였습니다.")
      }
    } else if indexPath.section == 5 {
      onShowDefaultImages?(settingList[indexPath.section])
    } else if indexPath.section == 6 {
      onExportRecords?()
    } else {
      onShowDetail?(indexPath.section, settingList[indexPath.section])
    }
  }
}

// MARK: - TableViewDataSource
extension SettingViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return settingList.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier) as? SettingTableViewCell else { return UITableViewCell() }
    cell.titleLabel.text = settingList[indexPath.section]
    return cell
  }
}
