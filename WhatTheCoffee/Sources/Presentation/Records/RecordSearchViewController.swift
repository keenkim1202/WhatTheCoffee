import UIKit

class RecordSearchViewController: UIViewController {

  // MARK: - Metric
  struct Metric {
    static var spacing: CGFloat = 10
    static var cellForItemCount: CGFloat = 2
  }

  // MARK: - Properties
  let viewModel: RecordSearchViewModel
  let container: DIContainer
  let cellInsets = UIEdgeInsets(top: Metric.spacing, left: Metric.spacing, bottom: Metric.spacing, right: Metric.spacing)

  // MARK: - UI
  private let searchCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 10
    layout.minimumInteritemSpacing = 10
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .systemBackground
    cv.register(RecordCollectionViewCell.self, forCellWithReuseIdentifier: RecordCollectionViewCell.identifier)
    cv.translatesAutoresizingMaskIntoConstraints = false
    return cv
  }()

  private let emptyView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(named: "GreenMainColor")
    view.isHidden = true
    view.translatesAutoresizingMaskIntoConstraints = false

    let stack = UIStackView()
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 10
    stack.translatesAutoresizingMaskIntoConstraints = false

    let label1 = UILabel()
    label1.text = "검색어와 관련된 카페기록이 없어요🥲"
    label1.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label1.textColor = UIColor(named: "GreenSubColor")

    let label2 = UILabel()
    label2.text = "확인 후 다시 검색을 시도해주세요!"
    label2.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label2.textColor = UIColor(named: "OrangeMainColor")

    stack.addArrangedSubview(label1)
    stack.addArrangedSubview(label2)
    view.addSubview(stack)

    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
    ])
    return view
  }()

  // MARK: - Init
  init(viewModel: RecordSearchViewModel, container: DIContainer) {
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
    configureLayout()
    configure()
    bindViewModel()
    addNotiObserver()
  }

  deinit {
    removeNotiObserver()
  }

  private func bindViewModel() {
    viewModel.onResultsUpdated = { [weak self] in
      guard let self else { return }
      searchCollectionView.reloadData()
      emptyView.isHidden = !viewModel.isEmpty
    }
  }

  private func addNotiObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(didDismissAddRercordNotification), name: NSNotification.Name("DismissAddRecord"), object: nil)
  }

  // MARK: - Notification Observers
  private func removeNotiObserver() {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name("DismissAddRecord"), object: nil)
  }

  @objc private func didDismissAddRercordNotification(_ notification: Notification) {
    DispatchQueue.main.async {
      if let query = self.navigationController?.navigationBar.topItem?.searchController?.searchBar.text {
        self.viewModel.search(query: query)
      }
    }
  }

  // MARK: - Configure
  private func configure() {
    searchCollectionView.delegate = self
    searchCollectionView.dataSource = self
  }

  private func configureLayout() {
    view.backgroundColor = .systemBackground
    view.addSubview(searchCollectionView)
    view.addSubview(emptyView)

    NSLayoutConstraint.activate([
      searchCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      searchCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      searchCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      searchCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

      emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      emptyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      emptyView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }
}

// MARK: - UICollectionViewDataSource
extension RecordSearchViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: RecordCollectionViewCell.identifier, for: indexPath) as? RecordCollectionViewCell else { return UICollectionViewCell() }
    let item = viewModel.cafe(at: indexPath.item)
    cell.backgroundImageView.image = viewModel.cafeImage(at: indexPath.item)
    cell.cellConfigure(with: item)
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension RecordSearchViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return cellInsets
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    searchCollectionView.deselectItem(at: indexPath, animated: true)
    let cafe = viewModel.cafe(at: indexPath.item)
    let vc = AddRecordViewController(viewModel: container.makeAddRecordViewModel(cafe: cafe))
    present(vc, animated: true)
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RecordSearchViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let screenSize = UIScreen.main.bounds.size
    let spacing = Metric.spacing * (Metric.cellForItemCount - 1 + 2)
    let width = (screenSize.width - spacing) / Metric.cellForItemCount
    return CGSize(width: width, height: width)
  }
}
