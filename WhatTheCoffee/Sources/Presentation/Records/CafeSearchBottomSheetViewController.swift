import UIKit
import CoreLocation

protocol CafeSearchBottomSheetDelegate: AnyObject {
  func didSelectCafe(_ location: SelectedLocation)
}

class CafeSearchBottomSheetViewController: UIViewController {

  // MARK: - Properties
  weak var delegate: CafeSearchBottomSheetDelegate?

  /// 고른 카페의 상세를 어떻게 띄울지는 Coordinator가 정한다. 확정되면 confirm을 부른다.
  var onShowCafeDetail: ((NearCafeEntity, @escaping () -> Void) -> Void)?
  var initialQuery: String?

  private let fetchUseCase = FetchNearCafeUseCase()
  private let locationManager = CLLocationManager()
  private var currentLocation: CLLocationCoordinate2D?
  private var cafeList: [NearCafeEntity] = []

  // MARK: - UI
  private let searchBar: UISearchBar = {
    let bar = UISearchBar()
    bar.placeholder = "카페 이름으로 검색해보세요!"
    bar.searchBarStyle = .minimal
    bar.translatesAutoresizingMaskIntoConstraints = false
    return bar
  }()

  private let tableView: UITableView = {
    let tv = UITableView()
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.register(UITableViewCell.self, forCellReuseIdentifier: "CafeSearchCell")
    return tv
  }()

  private let resultCountLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.GowunBatang(type: .regular, size: 13)
    label.textColor = .gray
    label.isHidden = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let emptyLabel: UILabel = {
    let label = UILabel()
    label.text = "일치하는 카페가 없어요 🥲"
    label.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label.textColor = UIColor(named: "OrangeMainColor")
    label.textAlignment = .center
    label.isHidden = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .appearanceColor
    configureUI()
    configureLocation()
    searchBar.delegate = self
    tableView.delegate = self
    tableView.dataSource = self

    if let initialQuery, !initialQuery.isEmpty {
      searchBar.text = initialQuery
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if let query = searchBar.text, !query.isEmpty {
      search(query: query)
    } else {
      searchNearbyCafes()
    }
  }

  // MARK: - Configure
  private func configureUI() {
    view.addSubview(searchBar)
    view.addSubview(resultCountLabel)
    view.addSubview(tableView)
    view.addSubview(emptyLabel)

    NSLayoutConstraint.activate([
      searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
      searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
      searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

      resultCountLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
      resultCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      resultCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

      tableView.topAnchor.constraint(equalTo: resultCountLabel.bottomAnchor, constant: 4),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
      emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)])
  }

  private func configureLocation() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    if CLLocationManager.locationServicesEnabled() {
      locationManager.startUpdatingLocation()
    }
  }

  // MARK: - Search
  private func search(query: String) {
    guard let location = currentLocation else { return }
    cafeList.removeAll()
    fetchUseCase.execute(latitude: location.latitude, longitude: location.longitude, query: query, page: 1) { [weak self] result in
      guard let self else { return }

      DispatchQueue.main.async {
        switch result {
        case .success(let page):
          self.cafeList = page.cafes
          self.emptyLabel.text = "검색 결과가 없어요"
          self.resultCountLabel.text = "검색 결과: \(page.cafes.count)개"
        case .failure(let error):
          self.cafeList = []
          self.emptyLabel.text = error.localizedDescription
          self.resultCountLabel.text = nil
        }

        self.tableView.reloadData()
        self.emptyLabel.isHidden = !self.cafeList.isEmpty
        self.resultCountLabel.isHidden = self.resultCountLabel.text == nil
      }
    }
  }

  private func searchNearbyCafes() {
    search(query: "카페")
  }
}

// MARK: - UISearchBarDelegate
extension CafeSearchBottomSheetViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    guard let query = searchBar.text, !query.isEmpty else { return }
    search(query: query)
  }
}

// MARK: - UITableViewDataSource
extension CafeSearchBottomSheetViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cafeList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CafeSearchCell")
    let cafe = cafeList[indexPath.row]

    cell.textLabel?.text = cafe.name
    cell.textLabel?.font = UIFont.GowunBatang(type: .regular, size: 15)
    cell.detailTextLabel?.text = cafe.address
    cell.detailTextLabel?.textColor = .gray
    cell.detailTextLabel?.font = UIFont.GowunBatang(type: .regular, size: 12)

    let selectButton = UIButton(type: .system)
    selectButton.setTitle("선택", for: .normal)
    selectButton.titleLabel?.font = UIFont.GowunBatang(type: .regular, size: 13)
    selectButton.tintColor = .orangeMainColor
    selectButton.sizeToFit()
    selectButton.tag = indexPath.row
    selectButton.addTarget(self, action: #selector(onSelectButton(_:)), for: .touchUpInside)
    cell.accessoryView = selectButton

    cell.backgroundColor = .appearanceColor
    return cell
  }

  @objc private func onSelectButton(_ sender: UIButton) {
    select(cafeList[sender.tag])
  }

  /// 목록에서 바로 고르든 상세를 거쳐 고르든 결과는 같다.
  private func select(_ cafe: NearCafeEntity) {
    let location = SelectedLocation(
      name: cafe.name, address: cafe.address,
      latitude: cafe.latitude, longitude: cafe.longitude)
    delegate?.didSelectCafe(location)
    dismiss(animated: true)
  }
}

// MARK: - UITableViewDelegate
extension CafeSearchBottomSheetViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let cafe = cafeList[indexPath.row]
    onShowCafeDetail?(cafe) { [weak self] in
      self?.select(cafe)
    }
  }
}

// MARK: - CLLocationManagerDelegate
extension CafeSearchBottomSheetViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      currentLocation = location.coordinate
      locationManager.stopUpdatingLocation()
    }
  }
}
