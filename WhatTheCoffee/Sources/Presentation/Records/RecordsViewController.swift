import UIKit
import FirebaseAnalytics

class RecordsViewController: BaseViewController {

  // MARK: - ModeType
  enum ModeType {
    case view
    case edit
  }

  // MARK: - Metric
  struct Metric {
    static var spacing: CGFloat = 10
    static var cellForItemCount: CGFloat = 2
  }

  // MARK: - Properties
  let cellInsets = UIEdgeInsets(top: Metric.spacing, left: Metric.spacing, bottom: Metric.spacing, right: Metric.spacing)
  var dictionarySelectedIndexPath: [IndexPath: Bool] = [:]
  let viewModel: RecordsViewModel
  let container: DIContainer

  var modeType: ModeType = .view {
    didSet {
      switch modeType {
      case .view:
        for (key, value) in dictionarySelectedIndexPath {
          if value {
            recordCollectionView.deselectItem(at: key, animated: true)
          }
        }
        dictionarySelectedIndexPath.removeAll()

        recordCollectionView.allowsMultipleSelection = false
        deleteBarButtonItem.isEnabled = false
        addBarButtonItem.isEnabled = true
        editBarButtonItem.title = "편집"
      case .edit:
        recordCollectionView.allowsMultipleSelection = true
        deleteBarButtonItem.isEnabled = true
        addBarButtonItem.isEnabled = false
        editBarButtonItem.title = "취소"
      }
    }
  }

  // MARK: - UI
  private let recordCollectionView: UICollectionView = {
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
    label1.text = "방문한 카페가 아직 없으신가요? 🥲"
    label1.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label1.textColor = UIColor(named: "GreenSubColor")

    let label2 = UILabel()
    label2.text = "있으시다면, 추가해보는게 어떤가요?"
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

  private lazy var addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAdd))
  private lazy var editBarButtonItem = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(onEdit))
  private lazy var deleteBarButtonItem: UIBarButtonItem = {
    let item = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(onDelete))
    item.tintColor = .red
    item.isEnabled = false
    return item
  }()

  // MARK: - Init
  init(viewModel: RecordsViewModel, container: DIContainer) {
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
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Analytics.logEvent("TAB_records", parameters: nil)
    viewModel.fetchData()
  }

  private func bindViewModel() {
    viewModel.onCafeListUpdated = { [weak self] in
      guard let self else { return }
      recordCollectionView.reloadData()
      emptyView.isHidden = !viewModel.isEmpty
    }
  }

  // MARK: - Configure
  private func configure() {
    recordCollectionView.delegate = self
    recordCollectionView.dataSource = self
  }

  private func configureNav() {
    let titleLabel = UILabel()
    titleLabel.text = "커피 기록_"
    titleLabel.font = UIFont(name: "GowunBatang-Bold", size: 15)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    navigationItem.rightBarButtonItems = [addBarButtonItem, editBarButtonItem, deleteBarButtonItem]
  }

  private func configureLayout() {
    view.backgroundColor = .systemBackground
    view.addSubview(recordCollectionView)
    view.addSubview(emptyView)

    NSLayoutConstraint.activate([
      recordCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      recordCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      recordCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      recordCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

      emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      emptyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      emptyView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }

  private func configureSearchController() {
    let searchVC = RecordSearchViewController(viewModel: container.makeRecordSearchViewModel(), container: container)
    let searchController = UISearchController(searchResultsController: searchVC)

    searchController.searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
    searchController.searchBar.delegate = self
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder = "카페 이름으로 검색해보세요!"

    definesPresentationContext = true
    navigationItem.searchController = searchController
  }

  private func changeDeleteButtonState() {
    modeType = modeType == .view ? .edit : .view
  }

  // MARK: - Actions
  @objc private func onDelete() {
    var deleteNeededIndexPaths: [IndexPath] = []
    for (key, value) in dictionarySelectedIndexPath {
      if value {
        deleteNeededIndexPaths.append(key)
      }
    }

    if deleteNeededIndexPaths.count > 0 {
      deleteAlert("\(deleteNeededIndexPaths.count)개의 기록을 삭제하시겠습니까?") {
        self.viewModel.deleteRecords(at: deleteNeededIndexPaths)
        self.dictionarySelectedIndexPath.removeAll()
      }
    } else {
      showErrorAlert("삭제할 기록을 선택해주세요.")
    }
  }

  @objc private func onEdit() {
    changeDeleteButtonState()
  }

  @objc private func onAdd() {
    let vc = AddRecordViewController(viewModel: container.makeAddRecordViewModel())
    present(vc, animated: true)
  }
}

// MARK: - UICollectionViewDelegate
extension RecordsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return cellInsets
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch modeType {
    case .view:
      recordCollectionView.deselectItem(at: indexPath, animated: true)
      let cafe = viewModel.cafe(at: indexPath.item)
      let vc = AddRecordViewController(viewModel: container.makeAddRecordViewModel(cafe: cafe))
      present(vc, animated: true)
    case .edit:
      dictionarySelectedIndexPath[indexPath] = true
    }
  }

  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    if modeType == .edit {
      dictionarySelectedIndexPath[indexPath] = false
    }
  }
}

// MARK: - UICollectionViewDataSource
extension RecordsViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = recordCollectionView.dequeueReusableCell(withReuseIdentifier: RecordCollectionViewCell.identifier, for: indexPath) as? RecordCollectionViewCell else { return UICollectionViewCell() }
    let item = viewModel.cafe(at: indexPath.item)
    cell.backgroundImageView.image = viewModel.cafeImage(at: indexPath.item)
    cell.cellConfigure(with: item)
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RecordsViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let screenSize = UIScreen.main.bounds.size
    let spacing = Metric.spacing * (Metric.cellForItemCount - 1 + 2)
    let width = (screenSize.width - spacing) / Metric.cellForItemCount
    return CGSize(width: width, height: width)
  }
}

// MARK: - UISearchBarDelegate
extension RecordsViewController: UISearchBarDelegate {
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    becomeFirstResponder()
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    recordCollectionView.reloadData()
  }
}

// MARK: - UISearchResultsUpdating
extension RecordsViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchVC = searchController.searchResultsController as! RecordSearchViewController
    guard let query = searchController.searchBar.text else { return }
    searchVC.viewModel.search(query: query)
  }
}
