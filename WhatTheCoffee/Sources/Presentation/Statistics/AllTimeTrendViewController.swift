import UIKit

/// 첫 방문부터 지금까지의 월별 추이.
/// 통계 탭의 차트는 최근 6개월만 보여주므로 그보다 오래 다닌 이야기는 여기서만 보인다.
final class AllTimeTrendViewController: BaseViewController {

  // MARK: - Properties
  private let useCase: FetchStatisticsUseCase
  private var months: [(year: Int, month: Int, count: Int)] = []

  // MARK: - UI
  private let summaryLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.GowunBatang(type: .regular, size: 13)
    label.textColor = .secondaryLabel
    label.textAlignment = .center
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let scrollView: UIScrollView = {
    let sv = UIScrollView()
    sv.showsVerticalScrollIndicator = false
    sv.translatesAutoresizingMaskIntoConstraints = false
    return sv
  }()

  private let rowsStack: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 10
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  private let emptyLabel: UILabel = {
    let label = UILabel()
    label.text = "아직 방문 기록이 없어요"
    label.font = UIFont.GowunBatang(type: .regular, size: 15)
    label.textColor = .secondaryLabel
    label.textAlignment = .center
    label.isHidden = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  // MARK: - Init
  init(useCase: FetchStatisticsUseCase) {
    self.useCase = useCase
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
    observeForeground()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reload()
  }

  /// 이 화면이 떠 있는 동안 위젯이나 시리로 방문이 더해질 수 있다.
  /// 한 번 받은 값으로 두면 돌아왔을 때 지난 숫자를 보여준다.
  private func observeForeground() {
    NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main) { [weak self] _ in
        guard let self, viewIfLoaded?.window != nil else { return }
        reload()
      }
  }

  private func reload() {
    months = useCase.fetchAllTimeMonthlyVisits()
    configureRows()
  }

  // MARK: - Configure
  private func configureNav() {
    title = "전체 기간 추이"
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "닫기", style: .plain, target: self, action: #selector(onClose))
  }

  private func configureLayout() {
    view.backgroundColor = .systemBackground
    view.addSubview(summaryLabel)
    view.addSubview(scrollView)
    scrollView.addSubview(rowsStack)
    view.addSubview(emptyLabel)

    NSLayoutConstraint.activate([
      summaryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
      summaryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      summaryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

      scrollView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 16),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      rowsStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      rowsStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
      rowsStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
      rowsStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
      rowsStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),

      emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }

  private func configureRows() {
    rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

    guard !months.isEmpty else {
      emptyLabel.isHidden = false
      summaryLabel.text = nil
      return
    }
    emptyLabel.isHidden = true

    let total = months.reduce(0) { $0 + $1.count }
    let visited = months.filter { $0.count > 0 }.count
    summaryLabel.text = "\(months.count)개월 동안 \(total)번 · 다녀온 달 \(visited)개월"

    // 가장 많이 간 달을 기준으로 막대 길이를 잡는다.
    let maxCount = months.map(\.count).max() ?? 1
    for month in months.reversed() {
      rowsStack.addArrangedSubview(makeRow(month, maxCount: maxCount))
    }
  }

  /// 달이 몇 년치가 되면 세로 막대로는 좁아 읽히지 않는다. 가로 막대로 눕히고 스크롤한다.
  private func makeRow(_ month: (year: Int, month: Int, count: Int), maxCount: Int) -> UIView {
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false

    let monthLabel = UILabel()
    // 두 자리로 고정한다. %를 그대로 쓰면 2005년이 "5년"으로 찍힌다.
    monthLabel.text = String(format: "%02d년 %d월", month.year % 100, month.month)
    monthLabel.font = UIFont.GowunBatang(type: .regular, size: 12)
    monthLabel.textColor = month.count > 0 ? .label : .tertiaryLabel
    monthLabel.textAlignment = .right
    monthLabel.translatesAutoresizingMaskIntoConstraints = false

    let barBackground = UIView()
    barBackground.backgroundColor = .systemGray5
    barBackground.layer.cornerRadius = 4
    barBackground.translatesAutoresizingMaskIntoConstraints = false

    let barFill = UIView()
    barFill.backgroundColor = month.count > 0 ? .greenMainColor : .clear
    barFill.layer.cornerRadius = 4
    barFill.translatesAutoresizingMaskIntoConstraints = false

    let countLabel = UILabel()
    countLabel.text = "\(month.count)"
    countLabel.font = UIFont.GowunBatang(type: .regular, size: 12)
    countLabel.textColor = month.count > 0 ? .label : .tertiaryLabel
    countLabel.translatesAutoresizingMaskIntoConstraints = false

    container.addSubview(monthLabel)
    container.addSubview(barBackground)
    barBackground.addSubview(barFill)
    container.addSubview(countLabel)

    // 방문이 없는 달도 자리를 지켜야 뜸했던 시기가 드러난다.
    let ratio = maxCount == 0 ? 0 : CGFloat(month.count) / CGFloat(maxCount)

    NSLayoutConstraint.activate([
      container.heightAnchor.constraint(equalToConstant: 22),

      monthLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      monthLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      monthLabel.widthAnchor.constraint(equalToConstant: 64),

      barBackground.leadingAnchor.constraint(equalTo: monthLabel.trailingAnchor, constant: 10),
      barBackground.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      barBackground.heightAnchor.constraint(equalToConstant: 8),
      barBackground.trailingAnchor.constraint(equalTo: countLabel.leadingAnchor, constant: -10),

      barFill.leadingAnchor.constraint(equalTo: barBackground.leadingAnchor),
      barFill.topAnchor.constraint(equalTo: barBackground.topAnchor),
      barFill.bottomAnchor.constraint(equalTo: barBackground.bottomAnchor),
      barFill.widthAnchor.constraint(equalTo: barBackground.widthAnchor, multiplier: ratio),

      countLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      countLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      countLabel.widthAnchor.constraint(equalToConstant: 28)
    ])
    return container
  }

  // MARK: - Action
  @objc private func onClose() {
    dismiss(animated: true)
  }
}
