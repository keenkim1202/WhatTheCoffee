import UIKit

class SummaryCardView: UIView {

  private let visitCountLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "GowunBatang-Bold", size: 32)
    label.textColor = .greenMainColor
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let visitSubtitleLabel: UILabel = {
    let label = UILabel()
    label.text = "방문한 카페"
    label.font = UIFont.GowunBatang(type: .regular, size: 13)
    label.textColor = .gray
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let ratingLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "GowunBatang-Bold", size: 32)
    label.textColor = .orangeMainColor
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let ratingSubtitleLabel: UILabel = {
    let label = UILabel()
    label.text = "평균 별점"
    label.font = UIFont.GowunBatang(type: .regular, size: 13)
    label.textColor = .gray
    label.textAlignment = .center
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
    let visitCard = makeCard(valueLabel: visitCountLabel, subtitleLabel: visitSubtitleLabel)
    let ratingCard = makeCard(valueLabel: ratingLabel, subtitleLabel: ratingSubtitleLabel)

    let stack = UIStackView(arrangedSubviews: [visitCard, ratingCard])
    stack.axis = .horizontal
    stack.spacing = 12
    stack.distribution = .fillEqually
    stack.translatesAutoresizingMaskIntoConstraints = false

    addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor)])
  }

  private func makeCard(valueLabel: UILabel, subtitleLabel: UILabel) -> UIView {
    let card = UIView()
    card.backgroundColor = UIColor(named: "AppearanceColor")
    card.layer.cornerRadius = 12
    card.translatesAutoresizingMaskIntoConstraints = false

    let stack = UIStackView(arrangedSubviews: [valueLabel, subtitleLabel])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 4
    stack.translatesAutoresizingMaskIntoConstraints = false

    card.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: card.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
      card.heightAnchor.constraint(equalToConstant: 100)])
    return card
  }

  func configure(totalCount: Int, averageRating: Double) {
    visitCountLabel.text = "\(totalCount)"
    ratingLabel.text = String(format: "%.1f", averageRating)
  }
}
