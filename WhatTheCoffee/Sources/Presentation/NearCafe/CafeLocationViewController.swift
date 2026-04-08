import UIKit
import NMapsMap
import CoreLocation

class CafeLocationViewController: BaseViewController {

  // MARK: - Properties
  let nearCafeLists: [NearCafeEntity]
  var locationManger = CLLocationManager()
  var myLocation: CLLocationCoordinate2D?

  // MARK: - UI
  private let naverMapView: NMFNaverMapView = {
    let mapView = NMFNaverMapView()
    mapView.translatesAutoresizingMaskIntoConstraints = false
    return mapView
  }()

  // MARK: - Init
  init(nearCafeLists: [NearCafeEntity], myLocation: CLLocationCoordinate2D?) {
    self.nearCafeLists = nearCafeLists
    self.myLocation = myLocation
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
    configureLocationManager()

    if !nearCafeLists.isEmpty, let myLocation {
      moveCamera(lat: myLocation.latitude, long: myLocation.longitude)

      for cafe in nearCafeLists {
        pinMaker(lat: cafe.latitude, long: cafe.longitude, caption: cafe.name)
      }
    }
  }

  // MARK: - Configure
  private func configureNav() {
    title = "근처 카페 지도"
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(onClose))
  }

  private func configureLayout() {
    view.backgroundColor = .systemBackground
    view.addSubview(naverMapView)

    NSLayoutConstraint.activate([
      naverMapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      naverMapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      naverMapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      naverMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  func configureLocationManager() {
    locationManger.delegate = self
    locationManger.desiredAccuracy = kCLLocationAccuracyBest
    locationManger.requestWhenInUseAuthorization()

    naverMapView.showLocationButton = true

    if CLLocationManager.locationServicesEnabled() {
      locationManger.startUpdatingLocation()
      if let location = locationManger.location {
        myLocation = location.coordinate
      }
    }
  }

  // MARK: 지도 시점 이동
  private func moveCamera(lat: Double, long: Double) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: long))
    cameraUpdate.reason = 3
    cameraUpdate.animation = .fly
    cameraUpdate.animationDuration = 2
    naverMapView.mapView.moveCamera(cameraUpdate)
  }

  // MARK: 지도에 pin 찍기
  private func pinMaker(lat: Double, long: Double, caption: String) {
    let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: long))
    marker.touchHandler = { [weak self] _ in
      guard let self else { return true }
      if let cafe = nearCafeLists.first(where: { $0.name == caption }) {
        let popupVC = PopupViewController(cafe: cafe)
        popupVC.modalPresentationStyle = .overFullScreen
        present(popupVC, animated: false)
      }
      return true
    }

    marker.iconImage = NMFOverlayImage(name: "coffee_marker_shadow")
    marker.width = 30
    marker.height = 33
    marker.anchor = CGPoint(x: 1, y: 1)
    marker.captionText = caption
    marker.mapView = naverMapView.mapView
  }

  // MARK: - Action
  @objc private func onClose() {
    dismiss(animated: true)
  }
}

// MARK: - CLLocationManagerDelegate
extension CafeLocationViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      myLocation = location.coordinate
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
