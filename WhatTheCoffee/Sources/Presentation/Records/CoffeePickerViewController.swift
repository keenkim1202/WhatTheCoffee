import UIKit

/// 기록에 남길 커피를 커피 목록에서 고른다.
/// 피사체 고르기와 같은 방식으로 보여준다 — 스티커를 늘어놓고, 고른 것에 테두리를 준 뒤 적용 버튼으로 확정한다.
final class CoffeePickerViewController: BaseViewController {

  struct Choice {
    let coffee: CoffeeEntity?
    let image: UIImage?

    /// 아무것도 고르지 않는 자리. 목록 맨 앞에 둔다.
    static let none = Choice(coffee: nil, image: nil)
  }

  // MARK: - Properties
  private let choices: [Choice]
  private let onSelect: (CoffeeEntity?) -> Void

  private var selectedIndex: Int

  /// 윤곽선 렌더링은 무거워서 메인 스레드에서 하면 시트가 끊긴다. 미리 만들어 두고 도착하면 갈아 끼운다.
  private var outlines: [Int: UIImage] = [:]

  // MARK: - UI
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "무엇을 마셨나요?"
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
    cv.register(CoffeeCell.self, forCellWithReuseIdentifier: CoffeeCell.identifier)
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
  init(choices: [Choice], selectedID: String?, onSelect: @escaping (CoffeeEntity?) -> Void) {
    self.choices = [.none] + choices
    self.onSelect = onSelect
    self.selectedIndex = self.choices.firstIndex { $0.coffee?.id == selectedID } ?? 0
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
    let images = choices.map { $0.image }

    DispatchQueue.global(qos: .userInitiated).async {
      var rendered: [Int: UIImage] = [:]
      for (index, image) in images.enumerated() {
        guard let image else { continue }
        rendered[index] = StickerOutline.outlined(image, color: .white)
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
    let selected = choices[selectedIndex].coffee
    dismiss(animated: true) { [weak self] in
      self?.onSelect(selected)
    }
  }
}

// MARK: - UICollectionViewDataSource
extension CoffeePickerViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return choices.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: CoffeeCell.identifier, for: indexPath) as? CoffeeCell else {
      return UICollectionViewCell()
    }
    cell.configure(with: choices[indexPath.item], outline: outlines[indexPath.item])
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension CoffeePickerViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectedIndex = indexPath.item
  }
}

// MARK: - Cell
private final class CoffeeCell: UICollectionViewCell {
  static let identifier = "CoffeeCell"

  override var isSelected: Bool {
    didSet { updateSelectionStyle() }
  }

  private var plainImage: UIImage?
  private var outlinedImage: UIImage?

  private let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    // 잘라낸 커피가 배경 없이 떠 보이도록 칸 배경을 두지 않는다.
    iv.backgroundColor = .clear
    iv.tintColor = .secondaryLabel
    iv.layer.cornerRadius = 12
    iv.clipsToBounds = true
    iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.GowunBatang(type: .regular, size: 13)
    label.textAlignment = .center
    label.numberOfLines = 2
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

  func configure(with choice: CoffeePickerViewController.Choice, outline: UIImage?) {
    // 사진이 없는 자리는 무엇을 뜻하는지 기호로 보여준다.
    plainImage = choice.image ?? UIImage(systemName: "nosign")
    outlinedImage = outline
    titleLabel.text = choice.coffee?.name ?? "선택 안 함"
    updateSelectionStyle()
  }

  private func updateSelectionStyle() {
    imageView.image = isSelected ? (outlinedImage ?? plainImage) : plainImage
    titleLabel.textColor = isSelected ? UIColor(named: "GreenSubColor") : .secondaryLabel
  }
}
