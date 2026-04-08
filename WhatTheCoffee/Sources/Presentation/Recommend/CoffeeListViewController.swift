import UIKit

class CoffeeListViewController: BaseViewController {

  // MARK: - Properties
  let viewModel: CoffeeListViewModel
  let container: DIContainer

  // MARK: - UI
  private let tableView: UITableView = {
    let tv = UITableView()
    tv.backgroundColor = .systemBackground
    tv.separatorStyle = .singleLine
    tv.register(CoffeeListTableViewCell.self, forCellReuseIdentifier: CoffeeListTableViewCell.identifier)
    tv.translatesAutoresizingMaskIntoConstraints = false
    return tv
  }()

  private let emptyView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemBackground
    view.isHidden = true
    view.translatesAutoresizingMaskIntoConstraints = false

    let label = UILabel()
    label.text = "커피를 추가해주세요! ☕️"
    label.font = UIFont.GowunBatang(type: .regular, size: 15)
    label.textColor = UIColor(named: "OrangeMainColor")
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    return view
  }()

  // MARK: - Init
  init(viewModel: CoffeeListViewModel, container: DIContainer) {
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
    viewModel.fetchData()
  }

  // MARK: - Configure
  private func configureNav() {
    title = "커피 목록"
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(onClose))
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAdd))
  }

  private func configureLayout() {
    view.backgroundColor = .systemBackground

    view.addSubview(tableView)
    view.addSubview(emptyView)

    tableView.delegate = self
    tableView.dataSource = self

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

      emptyView.topAnchor.constraint(equalTo: view.topAnchor),
      emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }

  private func bindViewModel() {
    viewModel.onCoffeeListUpdated = { [weak self] in
      guard let self else { return }
      tableView.reloadData()
      emptyView.isHidden = !viewModel.isEmpty
    }
  }

  // MARK: - Swipe Actions
  private func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
    let action = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, success in
      self?.deleteAlert("정말 삭제하시겠습니까?") {
        self?.viewModel.deleteCoffee(at: indexPath.row)
      }
      success(true)
    }
    action.image = UIImage(systemName: "trash")
    action.backgroundColor = .systemRed
    return action
  }

  // MARK: - Actions
  @objc private func onClose() {
    dismiss(animated: true)
  }

  @objc private func onAdd() {
    let vc = AddCoffeeViewController(viewModel: container.makeAddCoffeeViewModel())
    navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: - UITableViewDelegate
extension CoffeeListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let coffee = viewModel.coffee(at: indexPath.row)
    let vc = AddCoffeeViewController(viewModel: container.makeAddCoffeeViewModel(coffee: coffee))
    navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: - UITableViewDataSource
extension CoffeeListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: CoffeeListTableViewCell.identifier) as? CoffeeListTableViewCell else { return UITableViewCell() }
    let coffee = viewModel.coffee(at: indexPath.row)
    cell.nameLabel.text = coffee.name
    cell.coffeeImageView.image = viewModel.coffeeImage(at: indexPath.row)
    return cell
  }

  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let delete = deleteAction(at: indexPath)
    return UISwipeActionsConfiguration(actions: [delete])
  }
}
