import UIKit

/// 자주 마신 커피와 그 커피의 평균 별점.
/// 자주 방문한 카페 카드와 같은 모양으로 두어 나란히 읽히게 한다.
final class TopCoffeesView: UIView {

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "자주 마신 커피 Top 5"
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
    label.text = "기록에 마신 커피를 남겨보세요"
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

    // 숨긴 쪽이 카드 높이를 함께 정하지 않도록 한 스택에 담는다.
    // UIStackView는 isHidden인 항목을 레이아웃에서 빼준다.
    let contentStack = UIStackView(arrangedSubviews: [rowsStack, emptyLabel])
    contentStack.axis = .vertical
    contentStack.translatesAutoresizingMaskIntoConstraints = false

    addSubview(titleLabel)
    addSubview(contentStack)

    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

      contentStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
      contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)])
  }

  func configure(topCoffees: [(name: String, count: Int, averageRating: Double)]) {
    rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

    if topCoffees.isEmpty {
      emptyLabel.isHidden = false
      rowsStack.isHidden = true
      return
    }
    emptyLabel.isHidden = true
    rowsStack.isHidden = false

    for (index, coffee) in topCoffees.enumerated() {
      rowsStack.addArrangedSubview(
        makeRow(rank: index + 1, name: coffee.name, count: coffee.count, rating: coffee.averageRating))
    }
  }

  private func makeRow(rank: Int, name: String, count: Int, rating: Double) -> UIView {
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

    // 몇 번 마셨는지와 그때 몇 점을 줬는지를 같이 보여야 "어느 게 좋았나"가 읽힌다.
    let detailLabel = UILabel()
    // 이 앱은 별점을 별 기호로 쓰지 않는다. 통계 요약과 같이 숫자로만 보여준다.
    detailLabel.text = String(format: "%d회 · 평점 %.1f", count, rating)
    detailLabel.font = UIFont.GowunBatang(type: .regular, size: 13)
    detailLabel.textColor = .gray
    detailLabel.textAlignment = .right
    detailLabel.setContentHuggingPriority(.required, for: .horizontal)
    detailLabel.translatesAutoresizingMaskIntoConstraints = false

    let stack = UIStackView(arrangedSubviews: [rankLabel, nameLabel, detailLabel])
    stack.axis = .horizontal
    stack.spacing = 8
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }
}
