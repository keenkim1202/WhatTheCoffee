import UIKit

class TopCafesView: UIView {

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "자주 방문한 카페 Top 5"
    label.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let rowsStack: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
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
    addSubview(rowsStack)
    addSubview(emptyLabel)

    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

      rowsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
      rowsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      rowsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      rowsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

      emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      emptyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
      emptyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)])
  }

  func configure(topCafes: [(name: String, count: Int)]) {
    rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

    if topCafes.isEmpty {
      emptyLabel.isHidden = false
      rowsStack.isHidden = true
      return
    }
    emptyLabel.isHidden = true
    rowsStack.isHidden = false

    for (index, cafe) in topCafes.enumerated() {
      let row = makeRow(rank: index + 1, name: cafe.name, count: cafe.count)
      rowsStack.addArrangedSubview(row)
    }
  }

  private func makeRow(rank: Int, name: String, count: Int) -> UIView {
    let rankLabel = UILabel()
    rankLabel.text = "\(rank)"
    rankLabel.font = UIFont(name: "GowunBatang-Bold", size: 15)
    rankLabel.textColor = rank <= 3 ? .orangeMainColor : .gray
    rankLabel.textAlignment = .center
    rankLabel.translatesAutoresizingMaskIntoConstraints = false
    rankLabel.widthAnchor.constraint(equalToConstant: 24).isActive = true

    let nameLabel = UILabel()
    nameLabel.text = name
    nameLabel.font = UIFont.GowunBatang(type: .regular, size: 14)
    nameLabel.translatesAutoresizingMaskIntoConstraints = false

    let countLabel = UILabel()
    countLabel.text = "\(count)회"
    countLabel.font = UIFont.GowunBatang(type: .regular, size: 13)
    countLabel.textColor = .gray
    countLabel.textAlignment = .right
    countLabel.translatesAutoresizingMaskIntoConstraints = false

    let stack = UIStackView(arrangedSubviews: [rankLabel, nameLabel, countLabel])
    stack.axis = .horizontal
    stack.spacing = 8
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }
}
