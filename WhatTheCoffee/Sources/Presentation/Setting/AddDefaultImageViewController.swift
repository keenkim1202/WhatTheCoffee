import UIKit

class AddDefaultImageViewController: BaseViewController {

  // MARK: - Property
  let container: DIContainer

  // MARK: - UI
  private let tableView: UITableView = {
    let tv = UITableView()
    tv.sectionHeaderHeight = 28
    tv.sectionFooterHeight = 28
    tv.register(AddDefaultImageTableViewCell.self, forCellReuseIdentifier: AddDefaultImageTableViewCell.identifier)
    tv.translatesAutoresizingMaskIntoConstraints = false
    return tv
  }()

  // MARK: - Init
  init(container: DIContainer) {
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
    configure()
  }

  // MARK: - Configure
  private func configure() {
    tableView.delegate = self
    tableView.dataSource = self
  }

  private func configureNav() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(onClose))
  }

  private func configureLayout() {
    view.backgroundColor = .systemBackground
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }

  // MARK: - Action
  @objc private func onClose() {
    dismiss(animated: true)
  }
}

// MARK: - Extension
extension AddDefaultImageViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return CoffeeNameList.defaultIceCoffeeList.count
    } else {
      return CoffeeNameList.defaultHotCoffeeList.count
    }
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "아이스 음료 목록"
    } else {
      return "따뜻한 음료 목록"
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: AddDefaultImageTableViewCell.identifier) as? AddDefaultImageTableViewCell else { return UITableViewCell() }

    if indexPath.section == 0 {
      let iceCoffee = CoffeeNameList.defaultIceCoffeeList[indexPath.row]
      cell.coffeeImageView.image = UIImage(named: iceCoffee) ?? UIImage.randomCoffeeImage
      cell.nameLabel.text = iceCoffee.replacingOccurrences(of: "_", with: " ")
    } else {
      let hotCoffee = CoffeeNameList.defaultHotCoffeeList[indexPath.row]
      cell.coffeeImageView.image = UIImage(named: hotCoffee) ?? UIImage.randomCoffeeImage
      cell.nameLabel.text = hotCoffee.replacingOccurrences(of: "_", with: " ")
    }
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let repo = container.coffeeRepository

    if indexPath.section == 0 {
      let iceCoffee = CoffeeNameList.defaultIceCoffeeList[indexPath.row]
      let image = UIImage(named: iceCoffee) ?? UIImage.randomCoffeeImage
      let name = iceCoffee.replacingOccurrences(of: "_", with: " ")

      addAlert("다음 커피를 추가하시겠습니까?", name) {
        let coffee = repo.add(name: name)
        self.saveImageToDocumentDirectory(type: .coffee, imageName: "coffee_\(coffee.id).jpg", image: image)
        self.showSuccessAlert("재추가에 성공하였습니다.")
      }
    } else {
      let hotCoffee = CoffeeNameList.defaultHotCoffeeList[indexPath.row]
      let image = UIImage(named: hotCoffee) ?? UIImage.randomCoffeeImage
      let name = hotCoffee.replacingOccurrences(of: "_", with: " ")

      addAlert("다음 커피를 추가하시겠습니까?", name) {
        let coffee = repo.add(name: name)
        self.saveImageToDocumentDirectory(type: .coffee, imageName: "coffee_\(coffee.id).jpg", image: image)
        self.showSuccessAlert("재추가에 성공하였습니다.")
      }
    }
  }
}
