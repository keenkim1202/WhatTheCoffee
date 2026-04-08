import UIKit
import CoreLocation
import FirebaseAnalytics

class NearCafeViewController: BaseViewController {

  // MARK: - Properties
  let viewModel: NearCafeViewModel
  let container: DIContainer
  var locationManger = CLLocationManager()
  var userCoordinate: CLLocationCoordinate2D?

  // MARK: - UI
  private let tableView: UITableView = {
    let tv = UITableView()
    tv.backgroundColor = .systemBackground
    tv.keyboardDismissMode = .onDrag
    tv.sectionHeaderHeight = 28
    tv.sectionFooterHeight = 28
    tv.register(NearCafeTableViewCell.self, forCellReuseIdentifier: NearCafeTableViewCell.identifier)
    tv.translatesAutoresizingMaskIntoConstraints = false
    return tv
  }()

  private let emptyLabel: UILabel = {
    let label = UILabel()
    label.text = "근처 카페를 찾지 못하였어요 🥲"
    label.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label.textColor = UIColor(named: "OrangeMainColor")
    label.textAlignment = .center
    label.isHidden = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  // MARK: - Init
  init(viewModel: NearCafeViewModel, container: DIContainer) {
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
    configureSearchController()
    configureLayout()
    configure()
    bindViewModel()
    locationManger.requestWhenInUseAuthorization()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Analytics.logEvent("TAB_nearCafe", parameters: nil)
    configureLocationManager()
    fetchData()
  }

  // MARK: - Configure
  private func configure() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.prefetchDataSource = self
  }

  private func configureNav() {
    title = "근처 카페 찾기"
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "재탐색", style: .plain, target: self, action: #selector(onRedo))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "지도 보기", style: .plain, target: self, action: #selector(onCafeLocation))
  }

  private func configureLayout() {
    view.backgroundColor = .systemBackground
    view.addSubview(tableView)
    view.addSubview(emptyLabel)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

      emptyLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
      emptyLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
      emptyLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
    ])
  }

  private func bindViewModel() {
    viewModel.onNearCafeListUpdated = { [weak self] in
      guard let self else { return }
      tableView.reloadData()
      emptyLabel.isHidden = !viewModel.isEmpty
    }
  }

  private func configureSearchController() {
    let searchController = UISearchController()
    searchController.searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
    searchController.delegate = self
    searchController.searchBar.delegate = self
    searchController.searchBar.placeholder = "카페 이름으로 검색해보세요!"
    definesPresentationContext = true
    navigationItem.searchController = searchController
  }

  func configureLocationManager() {
    locationManger.delegate = self
    locationManger.desiredAccuracy = kCLLocationAccuracyBest
    locationManger.requestWhenInUseAuthorization()

    if CLLocationManager.locationServicesEnabled() {
      locationManger.startUpdatingLocation()
      if let location = locationManger.location {
        userCoordinate = location.coordinate
      }
    }
  }

  func fetchData(query: String = "카페", page: Int = 1) {
    if let coor = userCoordinate {
      DispatchQueue.global().async {
        self.viewModel.fetchData(latitude: coor.latitude, longitude: coor.longitude, query: query, page: page)
      }
    }
  }

  // MARK: - Action
  @objc private func onRedo() {
    viewModel.reset()
    tableView.scroll(to: .top, animated: true)
    fetchData()
  }

  @objc private func onCafeLocation() {
    if !viewModel.isEmpty {
      let vc = CafeLocationViewController(nearCafeLists: viewModel.nearCafeList, myLocation: userCoordinate)
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = .fullScreen
      present(nav, animated: true)
    } else {
      showErrorAlert("지도에 표시할 카페가 없어요😅\n다시 검색해주세요.")
    }
  }
}

// MARK: - UITableViewDelegate
extension NearCafeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cafe = viewModel.cafe(at: indexPath.row)
    let vc = DetailNearCafeViewController(nearCafe: cafe)
    let nav = UINavigationController(rootViewController: vc)
    nav.title = cafe.name
    nav.modalPresentationStyle = .fullScreen
    present(nav, animated: true)
  }
}

// MARK: - UITableViewDataSourcePrefetching
extension NearCafeViewController: UITableViewDataSourcePrefetching {
  func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    for indexPath in indexPaths {
      if viewModel.shouldPrefetch(at: indexPath.row), let coor = userCoordinate {
        viewModel.loadNextPage(latitude: coor.latitude, longitude: coor.longitude)
      }
    }
  }

  func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
  }
}

// MARK: - UITableViewDataSource
extension NearCafeViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: NearCafeTableViewCell.identifier) as? NearCafeTableViewCell else { return UITableViewCell() }
    let row = viewModel.cafe(at: indexPath.row)
    cell.cellConfigure(row: row)
    cell.cafeImageView.image = UIImage.NearCafePlaceholder
    cell.selectionStyle = .none
    return cell
  }
}

// MARK: - CLLocationManagerDelegate
extension NearCafeViewController: CLLocationManagerDelegate {
  func getLocationUsagePermission() {
    locationManger.requestWhenInUseAuthorization()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      configureLocationManager()
      fetchData()
    case .restricted, .notDetermined:
      getLocationUsagePermission()
    case .denied:
      getLocationUsagePermission()
    default:
      break
    }
  }
}

// MARK: - UISearchBarDelegate
extension NearCafeViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    guard let query = searchBar.text else { return }
    viewModel.reset()
    viewModel.queryText = query
    fetchData(query: query)
  }

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    becomeFirstResponder()
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    tableView.reloadData()
  }
}

// MARK: - UISearchControllerDelegate
extension NearCafeViewController: UISearchControllerDelegate {
}
