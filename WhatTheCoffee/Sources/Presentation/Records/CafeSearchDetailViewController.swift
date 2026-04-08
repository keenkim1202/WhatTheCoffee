import UIKit
import NMapsMap

class CafeSearchDetailViewController: BaseViewController {

  // MARK: - Properties
  var nearCafe: NearCafeEntity?
  var onSelect: (() -> Void)?

  // MARK: - UI
  private let naverMapView: NMFNaverMapView = {
    let mapView = NMFNaverMapView()
    mapView.translatesAutoresizingMaskIntoConstraints = false
    mapView.showZoomControls = true
    mapView.layer.cornerRadius = 8
    mapView.clipsToBounds = true
    return mapView
  }()

  private let addressLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.GowunBatang(type: .regular, size: 14)
    label.textColor = .label
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let selectButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("선택하기", for: .normal)
    button.titleLabel?.font = UIFont.GowunBatang(type: .regular, size: 16)
    button.tintColor = .white
    button.backgroundColor = .greenMainColor
    button.layer.cornerRadius = 20
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .appearanceColor
    configureUI()
    configureData()
  }

  // MARK: - Configure
  private func configureUI() {
    let closeButton = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(onClose))
    navigationItem.leftBarButtonItem = closeButton

    view.addSubview(naverMapView)
    view.addSubview(addressLabel)
    view.addSubview(selectButton)

    NSLayoutConstraint.activate([
      naverMapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      naverMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      naverMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      naverMapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),

      addressLabel.topAnchor.constraint(equalTo: naverMapView.bottomAnchor, constant: 16),
      addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

      selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
      selectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      selectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      selectButton.heightAnchor.constraint(equalToConstant: 50)])

    selectButton.addTarget(self, action: #selector(onSelectTapped), for: .touchUpInside)
  }

  private func configureData() {
    guard let cafe = nearCafe else { return }
    title = cafe.name
    addressLabel.text = cafe.address

    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: cafe.latitude, lng: cafe.longitude))
    naverMapView.mapView.moveCamera(cameraUpdate)

    let marker = NMFMarker(position: NMGLatLng(lat: cafe.latitude, lng: cafe.longitude))
    marker.iconImage = NMFOverlayImage(name: "coffee_marker_shadow")
    marker.width = 30
    marker.height = 33
    marker.anchor = CGPoint(x: 1, y: 1)
    marker.captionText = cafe.name
    marker.mapView = naverMapView.mapView
  }

  // MARK: - Actions
  @objc private func onClose() {
    dismiss(animated: true)
  }

  @objc private func onSelectTapped() {
    dismiss(animated: true) { [weak self] in
      self?.onSelect?()
    }
  }
}
