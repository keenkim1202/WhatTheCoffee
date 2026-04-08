import UIKit
import FirebaseAnalytics

class StatisticsViewController: BaseViewController {

  // MARK: - Properties
  let viewModel: StatisticsViewModel

  // MARK: - UI
  private let scrollView: UIScrollView = {
    let sv = UIScrollView()
    sv.translatesAutoresizingMaskIntoConstraints = false
    return sv
  }()

  private let contentStack: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 20
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  private let summaryCard = SummaryCardView()
  private let monthlyChart = MonthlyVisitChartView()
  private let ratingDistribution = RatingDistributionView()
  private let topCafes = TopCafesView()

  private let emptyLabel: UILabel = {
    let label = UILabel()
    label.text = "아직 방문 기록이 없어요 ☕️\n카페를 방문하고 기록해보세요!"
    label.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label.textColor = UIColor(named: "OrangeMainColor")
    label.textAlignment = .center
    label.numberOfLines = 0
    label.isHidden = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  // MARK: - Init
  init(viewModel: StatisticsViewModel) {
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
    bindViewModel()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Analytics.logEvent("TAB_statistics", parameters: nil)
    viewModel.fetchData()
  }

  // MARK: - Configure
  private func configureNav() {
    let titleLabel = UILabel()
    titleLabel.text = "통계_"
    titleLabel.font = UIFont(name: "GowunBatang-Bold", size: 15)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
  }

  private func configureLayout() {
    view.backgroundColor = .systemBackground

    summaryCard.translatesAutoresizingMaskIntoConstraints = false
    monthlyChart.translatesAutoresizingMaskIntoConstraints = false
    ratingDistribution.translatesAutoresizingMaskIntoConstraints = false
    topCafes.translatesAutoresizingMaskIntoConstraints = false

    contentStack.addArrangedSubview(summaryCard)
    contentStack.addArrangedSubview(monthlyChart)
    contentStack.addArrangedSubview(ratingDistribution)
    contentStack.addArrangedSubview(topCafes)

    scrollView.addSubview(contentStack)
    view.addSubview(scrollView)
    view.addSubview(emptyLabel)

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

      contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
      contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
      contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
      contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
      contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),

      emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
  }

  private func bindViewModel() {
    viewModel.onStatisticsUpdated = { [weak self] in
      guard let self, let statistics = viewModel.statistics else { return }

      let isEmpty = statistics.totalVisitCount == 0
      scrollView.isHidden = isEmpty
      emptyLabel.isHidden = !isEmpty

      if !isEmpty {
        summaryCard.configure(totalCount: statistics.totalVisitCount, averageRating: statistics.averageRating)
        monthlyChart.configure(monthlyData: statistics.monthlyVisitCounts)
        ratingDistribution.configure(distribution: statistics.ratingDistribution)
        topCafes.configure(topCafes: statistics.topCafes)
      }
    }
  }
}
