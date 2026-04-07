import UIKit
import CoreLocation
import FirebaseAnalytics

class NearCafeViewController: BaseViewController {

  // MARK: - Properties
  var viewModel = NearCafeViewModel()
  var environment: Environment? = nil
  var locationManger = CLLocationManager()
  var userCoordinate: CLLocationCoordinate2D?

  // MARK: - UI
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var emptyLabel: UILabel!

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    configureSearchController()
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
  func configure() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.prefetchDataSource = self
  }

  func bindViewModel() {
    viewModel.onNearCafeListUpdated = { [weak self] in
      guard let self = self else { return }
      self.tableView.reloadData()
      self.emptyLabel.isHidden = !self.viewModel.isEmpty
    }
  }

  func configureSearchController() {
    let searchController = UISearchController()

    searchController.searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
    searchController.delegate = self
    searchController.searchBar.delegate = self
    searchController.searchBar.placeholder = "카페 이름으로 검색해보세요!"
    self.definesPresentationContext = true
    self.navigationItem.searchController = searchController
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
  @IBAction func onRedo(_ sender: UIBarButtonItem) {
    viewModel.reset()
    self.tableView.scroll(to: .top, animated: true)
    fetchData()
  }

  @IBAction func onCafeLocation(_ sender: UIBarButtonItem) {
    if !viewModel.isEmpty {
      guard let vc = storyboard?.instantiateViewController(withIdentifier: "cafeLocationVC") as? CafeLocationViewController else { return }
      vc.nearCafeLists = viewModel.nearCafeList
      vc.myLocation = userCoordinate

      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = .fullScreen
      self.present(nav, animated: true)
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
    guard let vc = storyboard?.instantiateViewController(withIdentifier: "detailNearCafeVC") as? DetailNearCafeViewController else { return }
    guard let environment = environment else { return }
    vc.environment = environment
    vc.nearCafe = viewModel.cafe(at: indexPath.row)

    let nav = UINavigationController(rootViewController: vc)
    nav.title = viewModel.cafe(at: indexPath.row).name
    nav.modalPresentationStyle = .fullScreen
    self.present(nav, animated: true)
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
    self.locationManger.requestWhenInUseAuthorization()
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
    self.becomeFirstResponder()
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    self.tableView.reloadData()
  }
}

// MARK: - UISearchControllerDelegate
extension NearCafeViewController: UISearchControllerDelegate {
}
