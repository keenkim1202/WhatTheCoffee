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

  /// 목록의 이름을 누르면 그 기록만 모아 보여준다.
  var onSelectCafe: ((String) -> Void)?

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
      attachTap(to: row, name: cafe.name)
      rowsStack.addArrangedSubview(row)
    }
  }

  private func attachTap(to row: UIView, name: String) {
    row.isUserInteractionEnabled = true
    let tap = NameTapGestureRecognizer(target: self, action: #selector(onNameTapped(_:)))
    tap.value = name
    row.addGestureRecognizer(tap)
  }

  @objc private func onNameTapped(_ gesture: NameTapGestureRecognizer) {
    onSelectCafe?(gesture.value)
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

/// 어느 줄을 눌렀는지 제스처가 함께 들고 있게 한다.
/// 줄은 매번 새로 만들어지므로 인덱스를 밖에 저장해두면 어긋난다.
final class NameTapGestureRecognizer: UITapGestureRecognizer {
  /// UIGestureRecognizer가 이미 name을 갖고 있어 다른 이름을 쓴다.
  var value = ""
}
