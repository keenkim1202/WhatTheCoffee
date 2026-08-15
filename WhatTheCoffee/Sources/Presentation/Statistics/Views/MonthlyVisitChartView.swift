import UIKit

class MonthlyVisitChartView: UIView {

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "월별 방문 횟수"
    label.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let chartContainer: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    // .bottom이면 컬럼이 내용 높이만 갖는데, 내용은 아래에서 위로만 묶여 있어 높이가 0으로 접힌다.
    // 막대가 컨테이너 밖에 그려져 눌러도 터치가 닿지 않았다. 채워서 컬럼 전체를 누를 수 있게 한다.
    stack.alignment = .fill
    stack.distribution = .fillEqually
    stack.spacing = 8
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  private let emptyLabel: UILabel = {
    let label = UILabel()
    label.text = "방문 기록이 없어요"
    label.font = UIFont.GowunBatang(type: .regular, size: 13)
    label.textColor = .gray
    label.textAlignment = .center
    label.isHidden = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let maxBarHeight: CGFloat = 120

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureLayout()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureLayout() {
    backgroundColor = UIColor(named: "AppearanceColor")
    layer.cornerRadius = 12

    addSubview(titleLabel)
    addSubview(chartContainer)
    addSubview(emptyLabel)

    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

      chartContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
      chartContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      chartContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      chartContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
      chartContainer.heightAnchor.constraint(equalToConstant: maxBarHeight + 40),

      emptyLabel.centerXAnchor.constraint(equalTo: chartContainer.centerXAnchor),
      emptyLabel.centerYAnchor.constraint(equalTo: chartContainer.centerYAnchor)])
  }

  /// 막대를 누르면 그달 기록을 보여준다. 숫자만 보여주고 끝나면 다음에 할 게 없다.
  var onSelectMonth: ((Int, Int) -> Void)?

  func configure(monthlyData: [(year: Int, month: Int, count: Int)]) {
    chartContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

    let maxCount = monthlyData.map(\.count).max() ?? 0

    if maxCount == 0 {
      emptyLabel.isHidden = false
      return
    }
    emptyLabel.isHidden = true

    let currentMonth = Calendar.current.component(.month, from: Date())
    for data in monthlyData {
      let isCurrent = data.month == currentMonth
      let column = makeColumn(month: data.month, count: data.count, maxCount: maxCount, isCurrent: isCurrent)
      // 기록이 없는 달은 눌러도 보여줄 게 없다.
      if data.count > 0 {
        column.isUserInteractionEnabled = true
        let tap = MonthTapGestureRecognizer(target: self, action: #selector(onMonthTapped(_:)))
        tap.year = data.year
        tap.month = data.month
        column.addGestureRecognizer(tap)
      }
      chartContainer.addArrangedSubview(column)
    }
  }

  @objc private func onMonthTapped(_ gesture: MonthTapGestureRecognizer) {
    onSelectMonth?(gesture.year, gesture.month)
  }

  private func makeColumn(month: Int, count: Int, maxCount: Int, isCurrent: Bool = false) -> UIView {
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false

    let countLabel = UILabel()
    countLabel.text = "\(count)"
    countLabel.font = .systemFont(ofSize: 11, weight: .semibold)
    let barColor: UIColor = isCurrent ? .orangeMainColor : .greenMainColor
    countLabel.textColor = barColor
    countLabel.textAlignment = .center
    countLabel.translatesAutoresizingMaskIntoConstraints = false

    let bar = UIView()
    bar.backgroundColor = barColor
    bar.layer.cornerRadius = 4
    bar.translatesAutoresizingMaskIntoConstraints = false

    let monthLabel = UILabel()
    monthLabel.text = "\(month)월"
    monthLabel.font = .systemFont(ofSize: 11)
    monthLabel.textColor = .gray
    monthLabel.textAlignment = .center
    monthLabel.translatesAutoresizingMaskIntoConstraints = false

    container.addSubview(countLabel)
    container.addSubview(bar)
    container.addSubview(monthLabel)

    let barHeight = maxCount > 0
      ? maxBarHeight * CGFloat(count) / CGFloat(maxCount)
      : 0

    NSLayoutConstraint.activate([
      monthLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      monthLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

      bar.bottomAnchor.constraint(equalTo: monthLabel.topAnchor, constant: -4),
      bar.centerXAnchor.constraint(equalTo: container.centerXAnchor),
      bar.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.6),
      bar.heightAnchor.constraint(equalToConstant: max(barHeight, 4)),

      countLabel.bottomAnchor.constraint(equalTo: bar.topAnchor, constant: -2),
      countLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
      // 내용이 컨테이너를 넘지 않도록 위쪽을 막아둔다.
      countLabel.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor)])
    return container
  }
}

/// 어느 달을 눌렀는지 제스처가 함께 들고 있게 한다.
/// 막대는 매번 새로 만들어지므로 인덱스를 밖에 저장해두면 어긋난다.
private final class MonthTapGestureRecognizer: UITapGestureRecognizer {
  var year = 0
  var month = 0
}
