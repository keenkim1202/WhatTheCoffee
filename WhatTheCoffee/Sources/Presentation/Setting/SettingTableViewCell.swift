import UIKit

class SettingTableViewCell: UITableViewCell {

  static let identifier = "settingCell"

  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "GowunBatang-Bold", size: 17)
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
    contentView.addSubview(titleLabel)
    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }
}
