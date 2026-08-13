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

  private let statusView = ListStatusView()

  /// 위치를 아직 못 얻어 미뤄둔 검색. 첫 좌표가 도착하면 실행한다.
  private var pendingQuery: String?

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
    // 다른 탭에서 기록을 추가하고 돌아왔을 수 있으니 다시 읽는다.
    viewModel.reloadRecords()
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
    view.addSubview(statusView)
    statusView.translatesAutoresizingMaskIntoConstraints = false
    statusView.onRetry = { [weak self] in self?.onRedo() }

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

      statusView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      statusView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      statusView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      statusView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
    ])
  }

  private func bindViewModel() {
    viewModel.onNearCafeListUpdated = { [weak self] in
      self?.tableView.reloadData()
    }

    viewModel.onStatusChanged = { [weak self] state in
      guard let self else { return }
      statusView.apply(state)
      // 로딩·안내 화면과 목록이 겹쳐 보이지 않도록 한쪽만 남긴다.
      tableView.isHidden = !statusView.isHidden
    }

    // 이미 목록이 있는데 추가 요청이 실패하면 화면을 비우지 않고 알림만 띄운다.
    viewModel.onLoadFailed = { [weak self] error in
      guard let self, !viewModel.isEmpty else { return }
      errorAlert(error: error)
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
    guard let coordinate = userCoordinate else {
      // 좌표가 아직 없다. 조용히 끝내면 재탐색을 눌러도 아무 일이 없다.
      // 도착하면 실행하도록 남겨두고, 기다리는 중임을 알린다.
      pendingQuery = query
      viewModel.showLocationStatus(.loading("현재 위치를 확인하는 중이에요"))
      return
    }

    viewModel.fetchData(latitude: coordinate.latitude, longitude: coordinate.longitude, query: query, page: page)
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
    let vc = DetailNearCafeViewController(nearCafe: cafe, container: container)
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
    // 기록해둔 가게면 그때 남긴 사진을, 아니면 기본 이미지를 쓴다.
    cell.cafeImageView.image = viewModel.recordedImage(for: row) ?? UIImage.NearCafePlaceholder
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
    guard let location = locations.last else { return }

    userCoordinate = location.coordinate
    // 좌표를 얻었으면 계속 갱신할 이유가 없다.
    manager.stopUpdatingLocation()

    // 좌표가 없어 미뤄둔 검색이 있으면 이제 실행한다.
    guard let query = pendingQuery else { return }
    pendingQuery = nil
    fetchData(query: query)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    guard viewModel.isEmpty else { return }
    pendingQuery = nil
    statusView.apply(.failed(.locationUnavailable))
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
