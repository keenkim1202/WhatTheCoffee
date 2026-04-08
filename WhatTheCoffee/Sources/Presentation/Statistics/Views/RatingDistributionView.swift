import UIKit

class RatingDistributionView: UIView {

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "별점 분포"
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

    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

      rowsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
      rowsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      rowsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      rowsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)])
  }

  func configure(distribution: [Int: Int]) {
    rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

    let maxCount = distribution.values.max() ?? 1

    for star in stride(from: 5, through: 1, by: -1) {
      let count = distribution[star] ?? 0
      let row = makeRow(star: star, count: count, maxCount: maxCount)
      rowsStack.addArrangedSubview(row)
    }
  }

  private func makeRow(star: Int, count: Int, maxCount: Int) -> UIView {
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false

    let starLabel = UILabel()
    starLabel.text = "\(star)"
    starLabel.font = .systemFont(ofSize: 13, weight: .semibold)
    starLabel.textAlignment = .center
    starLabel.translatesAutoresizingMaskIntoConstraints = false

    let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
    starIcon.tintColor = .orangeMainColor
    starIcon.translatesAutoresizingMaskIntoConstraints = false

    let barBackground = UIView()
    barBackground.backgroundColor = .systemGray5
    barBackground.layer.cornerRadius = 4
    barBackground.translatesAutoresizingMaskIntoConstraints = false

    let barFill = UIView()
    barFill.backgroundColor = .orangeMainColor
    barFill.layer.cornerRadius = 4
    barFill.translatesAutoresizingMaskIntoConstraints = false

    let countLabel = UILabel()
    countLabel.text = "\(count)"
    countLabel.font = .systemFont(ofSize: 12)
    countLabel.textColor = .gray
    countLabel.translatesAutoresizingMaskIntoConstraints = false

    container.addSubview(starLabel)
    container.addSubview(starIcon)
    container.addSubview(barBackground)
    barBackground.addSubview(barFill)
    container.addSubview(countLabel)

    let fillRatio: CGFloat = maxCount > 0 ? CGFloat(count) / CGFloat(maxCount) : 0

    NSLayoutConstraint.activate([
      container.heightAnchor.constraint(equalToConstant: 24),

      starLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      starLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      starLabel.widthAnchor.constraint(equalToConstant: 16),

      starIcon.leadingAnchor.constraint(equalTo: starLabel.trailingAnchor, constant: 2),
      starIcon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      starIcon.widthAnchor.constraint(equalToConstant: 14),
      starIcon.heightAnchor.constraint(equalToConstant: 14),

      barBackground.leadingAnchor.constraint(equalTo: starIcon.trailingAnchor, constant: 8),
      barBackground.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      barBackground.heightAnchor.constraint(equalToConstant: 12),

      barFill.leadingAnchor.constraint(equalTo: barBackground.leadingAnchor),
      barFill.topAnchor.constraint(equalTo: barBackground.topAnchor),
      barFill.bottomAnchor.constraint(equalTo: barBackground.bottomAnchor),
      barFill.widthAnchor.constraint(equalTo: barBackground.widthAnchor, multiplier: max(fillRatio, 0.02)),

      countLabel.leadingAnchor.constraint(equalTo: barBackground.trailingAnchor, constant: 8),
      countLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      countLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      countLabel.widthAnchor.constraint(equalToConstant: 30)])
    return container
  }
}
