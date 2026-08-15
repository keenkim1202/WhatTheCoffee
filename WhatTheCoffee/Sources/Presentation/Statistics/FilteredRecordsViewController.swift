import UIKit

/// 통계에서 눌러 들어온 기록 목록.
/// 조건만 다를 뿐 보여주는 것은 기록 탭과 같아서 셀도 그대로 쓴다.
final class FilteredRecordsViewController: BaseViewController {

  // MARK: - Properties
  private let viewModel: FilteredRecordsViewModel

  /// 기록을 눌렀을 때 어디로 갈지는 Coordinator가 정한다.
  var onSelectRecord: ((CafeEntity) -> Void)?

  // MARK: - UI
  private let summaryLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.GowunBatang(type: .regular, size: 13)
    label.textColor = .secondaryLabel
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 10
    layout.minimumInteritemSpacing = 10

    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .systemBackground
    cv.register(RecordCollectionViewCell.self, forCellWithReuseIdentifier: RecordCollectionViewCell.identifier)
    cv.translatesAutoresizingMaskIntoConstraints = false
    return cv
  }()

  private let emptyLabel: UILabel = {
    let label = UILabel()
    label.text = "해당하는 기록이 없어요"
    label.font = UIFont.GowunBatang(type: .regular, size: 15)
    label.textColor = .secondaryLabel
    label.textAlignment = .center
    label.isHidden = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  // MARK: - Init
  init(viewModel: FilteredRecordsViewModel) {
    self.viewModel = viewModel
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

    collectionView.delegate = self
    collectionView.dataSource = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // 기록을 고치고 돌아오면 조건에서 벗어났을 수 있다.
    viewModel.reload()
    collectionView.reloadData()
    updateSummary()
  }

  // MARK: - Configure
  private func configureNav() {
    title = viewModel.title
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "닫기", style: .plain, target: self, action: #selector(onClose))
  }

  private func configureLayout() {
    view.backgroundColor = .systemBackground
    view.addSubview(summaryLabel)
    view.addSubview(collectionView)
    view.addSubview(emptyLabel)

    NSLayoutConstraint.activate([
      summaryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
      summaryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      summaryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

      collectionView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 12),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }

  private func updateSummary() {
    summaryLabel.text = viewModel.summary
    emptyLabel.isHidden = !viewModel.isEmpty
  }

  // MARK: - Action
  @objc private func onClose() {
    dismiss(animated: true)
  }
}

// MARK: - UICollectionViewDataSource
extension FilteredRecordsViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: RecordCollectionViewCell.identifier, for: indexPath) as? RecordCollectionViewCell else {
      return UICollectionViewCell()
    }

    cell.backgroundImageView.image = viewModel.cafeImage(at: indexPath.item)
    cell.cellConfigure(
      with: viewModel.cafe(at: indexPath.item),
      coffeeImage: viewModel.coffeeImage(at: indexPath.item))
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension FilteredRecordsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    onSelectRecord?(viewModel.cafe(at: indexPath.item))
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FilteredRecordsViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    // 기록 탭과 같은 두 칸 배치라 눈이 옮겨 갈 때 낯설지 않다.
    let spacing: CGFloat = 10 * 3
    let width = (collectionView.bounds.width - spacing) / 2
    return CGSize(width: width, height: width)
  }
}
