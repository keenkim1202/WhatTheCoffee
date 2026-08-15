import UIKit

/// 기록에 남길 커피를 커피 목록에서 고른다.
/// 고르지 않는 것도 뜻이 있으므로 맨 위에 지우는 줄을 둔다.
final class CoffeePickerViewController: UIViewController {

  // MARK: - Properties
  private let coffeeNames: [String]
  private let selectedName: String?

  /// nil은 "선택 안 함"이다.
  var onSelect: ((String?) -> Void)?

  // MARK: - UI
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "무엇을 마셨나요?"
    label.font = UIFont(name: "GowunBatang-Bold", size: 17)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let tableView: UITableView = {
    let tv = UITableView()
    tv.backgroundColor = .clear
    tv.translatesAutoresizingMaskIntoConstraints = false
    return tv
  }()

  private let emptyLabel: UILabel = {
    let label = UILabel()
    label.text = "커피 목록이 비어 있어요\n추천 탭에서 먼저 추가해보세요"
    label.font = UIFont.GowunBatang(type: .regular, size: 14)
    label.textColor = .secondaryLabel
    label.textAlignment = .center
    label.numberOfLines = 0
    label.isHidden = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  // MARK: - Init
  init(coffeeNames: [String], selectedName: String?) {
    self.coffeeNames = coffeeNames
    self.selectedName = selectedName
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureLayout()

    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CoffeeCell")
    emptyLabel.isHidden = !coffeeNames.isEmpty
  }

  // MARK: - Configure
  private func configureLayout() {
    view.backgroundColor = .appearanceColor
    view.addSubview(titleLabel)
    view.addSubview(tableView)
    view.addSubview(emptyLabel)

    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

      tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
}

// MARK: - UITableViewDataSource
extension CoffeePickerViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // 첫 줄은 선택을 지우는 자리다.
    return coffeeNames.count + 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CoffeeCell", for: indexPath)
    let name = self.name(at: indexPath)

    var content = cell.defaultContentConfiguration()
    content.text = name ?? "선택 안 함"
    content.textProperties.font = UIFont.GowunBatang(type: .regular, size: 15)
    content.textProperties.color = name == nil ? .secondaryLabel : .label
    cell.contentConfiguration = content

    cell.backgroundColor = .clear
    cell.accessoryType = name == selectedName ? .checkmark : .none
    return cell
  }

  private func name(at indexPath: IndexPath) -> String? {
    return indexPath.row == 0 ? nil : coffeeNames[indexPath.row - 1]
  }
}

// MARK: - UITableViewDelegate
extension CoffeePickerViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let picked = name(at: indexPath)
    dismiss(animated: true) { [weak self] in
      self?.onSelect?(picked)
    }
  }
}
