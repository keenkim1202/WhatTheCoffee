import UIKit

class CoffeeListViewController: BaseViewController {

  // MARK: - Properties
  var viewModel: CoffeeListViewModel!
  var environment: Environment? = nil

  // MARK: - UI
  @IBOutlet weak var tableView: UITableView!
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
    viewModel.fetchData()
  }

  // MARK: - Configure
  func configure() {
    tableView.delegate = self
    tableView.dataSource = self
  }

  func bindViewModel() {
    viewModel.onCoffeeListUpdated = { [weak self] in
      guard let self = self else { return }
      self.tableView.reloadData()
      self.emptyView.isHidden = !self.viewModel.isEmpty
    }
  }

  // MARK: Swipe Actions
  func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
    let action = UIContextualAction(style: .destructive, title: "삭제") { action, view, success in
      self.deleteAlert("정말 삭제하시겠습니까?") {
        self.viewModel.deleteCoffee(at: indexPath.row)
      }
      success(true)
    }
    action.image = UIImage(systemName: "trash")
    action.backgroundColor = .systemRed

    return action
  }

  // MARK: - Actions
  @IBAction func onClose(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true)
  }

  @IBAction func onAdd(_ sender: UIBarButtonItem) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "addCoffeeVC") as! AddCoffeeViewController
    guard let env = environment else { return }
    vc.viewModel = AddCoffeeViewModel(coffeeRepository: env.coffeeRepository)

    self.navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: - UITableViewDelegate
extension CoffeeListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let vc = storyboard?.instantiateViewController(withIdentifier: "addCoffeeVC") as? AddCoffeeViewController else { return }
    guard let env = environment else { return }

    let coffee = viewModel.coffee(at: indexPath.row)
    vc.viewModel = AddCoffeeViewModel(coffeeRepository: env.coffeeRepository, coffee: coffee)

    self.navigationController?.pushViewController(vc, animated: true)
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
    cell.coffeeImageView.layer.cornerRadius = CGFloat(8)
    cell.nameLabel.font = UIFont.GowunBatang(type: .regular, size: 15)

    return cell
  }

  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let delete = deleteAction(at: indexPath)
    return UISwipeActionsConfiguration(actions:[delete])
  }
}
