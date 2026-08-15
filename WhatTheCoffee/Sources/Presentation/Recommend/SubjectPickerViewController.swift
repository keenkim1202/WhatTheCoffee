import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

/// 사진에서 여러 피사체를 찾았을 때 어느 것을 쓸지 고르게 한다.
/// 스티커 시트처럼 잘라낸 결과를 늘어놓고, 고른 것에 테두리를 준 뒤 적용 버튼으로 확정한다.
final class SubjectPickerViewController: BaseViewController {

  // MARK: - Properties
  private let subjects: [SubjectCutout.Subject]
  private let onSelect: (SubjectCutout.Subject) -> Void

  /// 목록이 뜨는 경우는 선택지가 둘 이상일 때뿐이라, 첫 번째를 미리 골라둔다.
  private var selectedIndex = 0

  /// 윤곽선 렌더링은 무거워서 메인 스레드에서 하면 시트가 끊긴다. 미리 만들어 두고 도착하면 갈아 끼운다.
  private var outlines: [Int: UIImage] = [:]

  // MARK: - UI
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "어떤 걸 쓸까요?"
    label.font = UIFont(name: "GowunBatang-Bold", size: 17)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.itemSize = CGSize(width: 110, height: 140)
    layout.minimumInteritemSpacing = 12
    layout.minimumLineSpacing = 12
    layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)

    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .clear
    cv.dataSource = self
    cv.delegate = self
    cv.register(SubjectCell.self, forCellWithReuseIdentifier: SubjectCell.identifier)
    cv.translatesAutoresizingMaskIntoConstraints = false
    return cv
  }()

  private let applyButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("적용하기", for: .normal)
    button.setTitleColor(UIColor(named: "GreenSubColor"), for: .normal)
    button.titleLabel?.font = UIFont(name: "GowunBatang-Bold", size: 16)
    button.backgroundColor = UIColor(named: "GreenMainColor")
    button.layer.cornerRadius = 12
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  // MARK: - Init
  init(subjects: [SubjectCutout.Subject], onSelect: @escaping (SubjectCutout.Subject) -> Void) {
    self.subjects = subjects
    self.onSelect = onSelect
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureLayout()
    selectCurrentItem()
    prepareOutlines()
  }

  private func selectCurrentItem() {
    collectionView.selectItem(
      at: IndexPath(item: selectedIndex, section: 0), animated: false, scrollPosition: [])
  }

  private func prepareOutlines() {
    let subjects = self.subjects
    // 스티커처럼 흰 테두리로 둘러 어떤 사진 위에서도 경계가 드러나게 한다.
    let color = UIColor.white

    DispatchQueue.global(qos: .userInitiated).async {
      var rendered: [Int: UIImage] = [:]
      for (index, subject) in subjects.enumerated() {
        rendered[index] = StickerOutline.outlined(subject.image, color: color)
      }

      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        outlines = rendered
        collectionView.reloadData()
        selectCurrentItem()
      }
    }
  }

  // MARK: - Configure
  private func configureLayout() {
    view.backgroundColor = .systemBackground
    view.addSubview(titleLabel)
    view.addSubview(collectionView)
    view.addSubview(applyButton)
    applyButton.addTarget(self, action: #selector(onApply), for: .touchUpInside)

    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

      collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -12),

      applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
      applyButton.heightAnchor.constraint(equalToConstant: 50)
    ])
  }

  // MARK: - Action
  @objc private func onApply() {
    let selected = subjects[selectedIndex]
    dismiss(animated: true) { [weak self] in
      self?.onSelect(selected)
    }
  }
}

// MARK: - UICollectionViewDataSource
extension SubjectPickerViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return subjects.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: SubjectCell.identifier, for: indexPath) as? SubjectCell else {
      return UICollectionViewCell()
    }
    cell.configure(with: subjects[indexPath.item], outline: outlines[indexPath.item])
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension SubjectPickerViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectedIndex = indexPath.item
  }
}

// MARK: - Cell
private final class SubjectCell: UICollectionViewCell {
  static let identifier = "SubjectCell"

  override var isSelected: Bool {
    didSet { updateSelectionStyle() }
  }

  /// 선택 표시는 피사체 모양을 따라 그린 윤곽선으로 한다. 사각 테두리보다 스티커에 가깝다.
  private var plainImage: UIImage?
  private var outlinedImage: UIImage?

  private let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    // 잘라낸 피사체가 배경 없이 떠 보이도록 칸 배경을 두지 않는다.
    iv.backgroundColor = .clear
    iv.layer.cornerRadius = 12
    iv.clipsToBounds = true
    iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.GowunBatang(type: .regular, size: 13)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(imageView)
    contentView.addSubview(titleLabel)

    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

      titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    ])

    updateSelectionStyle()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(with subject: SubjectCutout.Subject, outline: UIImage?) {
    plainImage = subject.image
    outlinedImage = outline
    titleLabel.text = subject.title
    updateSelectionStyle()
  }

  private func updateSelectionStyle() {
    // 누끼든 원본이든 이미지 모양을 따라 그린 윤곽선으로 표시한다.
    imageView.image = isSelected ? (outlinedImage ?? plainImage) : plainImage
    titleLabel.textColor = isSelected ? UIColor(named: "GreenSubColor") : .secondaryLabel
  }
}
