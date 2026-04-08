import UIKit
import NMapsMap
import CoreLocation

class RecordMapViewController: BaseViewController {

  // MARK: - Properties
  let viewModel: RecordsViewModel
  let container: DIContainer
  private var naverMapView: NMFNaverMapView!
  private let locationManager = CLLocationManager()
  private var myLocation: CLLocationCoordinate2D?
  private var markers: [NMFMarker] = []

  // MARK: - Init
  init(container: DIContainer) {
    self.container = container
    self.viewModel = container.makeRecordsViewModel()
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureMapView()
    configureLocationManager()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.fetchData()
    placeMarkers()
  }

  // MARK: - Configure
  private func configureMapView() {
    view.backgroundColor = .systemBackground

    naverMapView = NMFNaverMapView()
    naverMapView.showLocationButton = true
    naverMapView.showZoomControls = true
    naverMapView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(naverMapView)

    NSLayoutConstraint.activate([
      naverMapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      naverMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      naverMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      naverMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(onClose))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "폐점 체크", style: .plain, target: self, action: #selector(onCheckClosed))
    title = "나의 카페 지도"
  }

  private func configureLocationManager() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    if CLLocationManager.locationServicesEnabled() {
      locationManager.startUpdatingLocation()
    }
  }

  private func placeMarkers() {
    markers.forEach { $0.mapView = nil }
    markers.removeAll()

    let cafes = viewModel.cafeList.filter { $0.hasLocation }

    for cafe in cafes {
      guard let lat = cafe.latitude, let lng = cafe.longitude else { continue }
      let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: lng))
      marker.iconImage = NMFOverlayImage(name: "coffee_marker_shadow")
      marker.width = 30
      marker.height = 33
      marker.anchor = CGPoint(x: 1, y: 1)
      marker.captionText = cafe.name

      if cafe.isClosed {
        marker.captionColor = .systemRed
        marker.subCaptionText = "폐점 의심"
        marker.subCaptionColor = .systemRed
      }

      marker.touchHandler = { [weak self] _ in
        self?.showCafeInfo(cafe)
        return true
      }

      marker.mapView = naverMapView.mapView
      markers.append(marker)
    }

    if let myLocation {
      let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: myLocation.latitude, lng: myLocation.longitude))
      cameraUpdate.animation = .fly
      cameraUpdate.animationDuration = 1
      naverMapView.mapView.moveCamera(cameraUpdate)
    } else if let first = cafes.first, let lat = first.latitude, let lng = first.longitude {
      let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
      cameraUpdate.animation = .fly
      cameraUpdate.animationDuration = 1
      naverMapView.mapView.moveCamera(cameraUpdate)
    }
  }

  private func showCafeInfo(_ cafe: CafeEntity) {
    let dateString = DateFormatter.visitDateFormat.string(from: cafe.visitDate)
    let closedText = cafe.isClosed ? " (폐점 의심)" : ""
    let message = "방문일: \(dateString)\n별점: \(cafe.rate)점\(closedText)"

    let alert = UIAlertController(title: cafe.name, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    present(alert, animated: true)
  }

  // MARK: - Actions
  @objc private func onClose() {
    dismiss(animated: true)
  }

  @objc private func onCheckClosed() {
    let useCase = container.makeCheckClosedCafeUseCase()
    navigationItem.rightBarButtonItem?.isEnabled = false
    title = "폐점 여부 확인 중..."

    useCase.checkAll { [weak self] closedCount in
      guard let self else { return }
      title = "나의 카페 지도"
      navigationItem.rightBarButtonItem?.isEnabled = true
      viewModel.fetchData()
      placeMarkers()

      let message = closedCount > 0
        ? "\(closedCount)곳의 카페가 폐점 의심으로 표시되었습니다."
        : "모든 카페가 정상 운영 중입니다."
      let alert = UIAlertController(title: "폐점 체크 완료", message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "확인", style: .default))
      present(alert, animated: true)
    }
  }
}

// MARK: - CLLocationManagerDelegate
extension RecordMapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      myLocation = location.coordinate
      locationManager.stopUpdatingLocation()

      let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude))
      cameraUpdate.animation = .fly
      cameraUpdate.animationDuration = 1
      naverMapView.mapView.moveCamera(cameraUpdate)
    }
  }
}
