import UIKit
import NMapsMap
import CoreLocation

class DetailNearCafeViewController: BaseViewController {

  // MARK: - Properties
  let nearCafe: NearCafeEntity

  // MARK: - UI
  private let infoTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "가게 정보"
    label.font = UIFont(name: "GowunBatang-Bold", size: 17)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let backgroundView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 8
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private let addressTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "주소"
    label.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let addressLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.GowunBatang(type: .regular, size: 14)
    label.textColor = UIColor(named: "OrangeMainColor")
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var detailInfoButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("상세 페이지 보기", for: .normal)
    button.setTitleColor(UIColor(named: "GreenSubColor"), for: .normal)
    button.titleLabel?.font = UIFont(name: "GowunBatang-Bold", size: 15)
    button.backgroundColor = UIColor(named: "GreenMainColor")
    button.addTarget(self, action: #selector(onDetailInfo), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let locationTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "위치"
    label.font = UIFont(name: "GowunBatang-Bold", size: 17)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let naverMapView: NMFNaverMapView = {
    let mapView = NMFNaverMapView()
    mapView.layer.cornerRadius = 8
    mapView.translatesAutoresizingMaskIntoConstraints = false
    return mapView
  }()

  // MARK: - Init
  init(nearCafe: NearCafeEntity) {
    self.nearCafe = nearCafe
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
  private func configureNav() {
    title = nearCafe.name
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(onClose))
  }

  private func configure() {
    addressLabel.text = nearCafe.address
    naverMapView.showZoomControls = true
    moveCamera(lat: nearCafe.latitude, long: nearCafe.longitude)
    pinMaker(lat: nearCafe.latitude, long: nearCafe.longitude, caption: nearCafe.name)
  }

  private func configureLayout() {
    view.backgroundColor = .systemBackground

    let addressStack = UIStackView(arrangedSubviews: [addressTitleLabel, addressLabel])
    addressStack.axis = .vertical
    addressStack.alignment = .leading
    addressStack.translatesAutoresizingMaskIntoConstraints = false

    backgroundView.addSubview(addressStack)
    backgroundView.addSubview(detailInfoButton)

    view.addSubview(infoTitleLabel)
    view.addSubview(backgroundView)
    view.addSubview(locationTitleLabel)
    view.addSubview(naverMapView)

    NSLayoutConstraint.activate([
      infoTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
      infoTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      infoTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

      backgroundView.topAnchor.constraint(equalTo: infoTitleLabel.bottomAnchor, constant: 10),
      backgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      backgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
      backgroundView.widthAnchor.constraint(equalTo: backgroundView.heightAnchor, multiplier: 3),

      addressStack.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 15),
      addressStack.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10),
      addressStack.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10),

      detailInfoButton.topAnchor.constraint(equalTo: addressStack.bottomAnchor, constant: 20),
      detailInfoButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
      detailInfoButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
      detailInfoButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10),

      locationTitleLabel.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 50),
      locationTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      locationTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

      naverMapView.topAnchor.constraint(equalTo: locationTitleLabel.bottomAnchor, constant: 10),
      naverMapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      naverMapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
      naverMapView.widthAnchor.constraint(equalTo: naverMapView.heightAnchor, multiplier: 1.3)
    ])
  }

  // MARK: 지도 시점 이동
  private func moveCamera(lat: Double, long: Double) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: long))
    cameraUpdate.reason = 3
    cameraUpdate.animation = .none
    cameraUpdate.animationDuration = 2
    naverMapView.mapView.moveCamera(cameraUpdate)
  }

  // MARK: 지도에 pin 찍기
  private func pinMaker(lat: Double, long: Double, caption: String) {
    let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: long))
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

  @objc private func onDetailInfo() {
    let vc = SettingDetailViewController(url: nearCafe.placeUrl)
    vc.title = nearCafe.name
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    present(nav, animated: true)
  }
}
