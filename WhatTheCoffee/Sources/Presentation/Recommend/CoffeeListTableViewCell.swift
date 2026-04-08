import UIKit

class CoffeeListTableViewCell: UITableViewCell {

  static let identifier = "coffeeCell"

  let coffeeImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    iv.layer.cornerRadius = 8
    iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()

  let nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.GowunBatang(type: .regular, size: 15)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureLayout()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureLayout() {
    let stack = UIStackView(arrangedSubviews: [coffeeImageView, nameLabel])
    stack.axis = .horizontal
    stack.alignment = .center
    stack.spacing = 20
    stack.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

      coffeeImageView.widthAnchor.constraint(equalTo: coffeeImageView.heightAnchor)
    ])
  }
}
