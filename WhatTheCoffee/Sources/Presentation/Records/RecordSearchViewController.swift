import UIKit

class RecordSearchViewController: UIViewController {

  // MARK: - Metric
  struct Metric {
    static var spacing: CGFloat = 10
    static var cellForItemCount: CGFloat = 2
  }

  // MARK: - Properties
  var viewModel: RecordSearchViewModel!
  var container: DIContainer!
  let cellInsets = UIEdgeInsets(top: Metric.spacing, left: Metric.spacing, bottom: Metric.spacing, right: Metric.spacing)

  // MARK: - UI
  @IBOutlet weak var searchCollectionView: UICollectionView!
  @IBOutlet weak var emptyView: UIView!

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
    bindViewModel()
    addNotiObserver()
  }

  deinit {
    removeNotiObserver()
  }

  func bindViewModel() {
    viewModel.onResultsUpdated = { [weak self] in
      guard let self = self else { return }
      self.searchCollectionView.reloadData()
      self.emptyView.isHidden = !self.viewModel.isEmpty
    }
  }

  func addNotiObserver() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didDismissAddRercordNotification),
      name: NSNotification.Name("DismissAddRecord"),
      object: nil)
  }

  // MARK: - Notification Observers
  func removeNotiObserver() {
    NotificationCenter.default.removeObserver(
      self,
      name: NSNotification.Name("DismissAddRecord"),
      object: nil)
  }

  @objc func didDismissAddRercordNotification(_ notification: Notification) {
    DispatchQueue.main.async {
      // Re-search with same query to refresh results after editing a record
      if let query = self.navigationController?.navigationBar.topItem?.searchController?.searchBar.text {
        self.viewModel.search(query: query)
      }
    }
  }

  // MARK: - Configure
  func configure() {
    let layout = UICollectionViewFlowLayout()
    searchCollectionView.collectionViewLayout = layout

    searchCollectionView.delegate = self
    searchCollectionView.dataSource = self
    searchCollectionView.register(UINib(nibName: "RecordCell", bundle: nil), forCellWithReuseIdentifier: RecordCollectionViewCell.identifier)
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

    guard let vc = storyboard?.instantiateViewController(withIdentifier: "addRecordVC") as? AddRecordViewController else { return }
    let cafe = viewModel.cafe(at: indexPath.item)
    vc.viewModel = container.makeAddRecordViewModel(cafe: cafe)

    self.present(vc, animated: true)
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
