import UIKit

class NearCafeTableViewCell: UITableViewCell {

  static let identifier = "nearCafeCell"

  let cafeImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.layer.cornerRadius = 8
    iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()

  let cafeNameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  let addressLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.GowunBatang(type: .regular, size: 13)
    label.textColor = .opaqueSeparator
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  let distanceLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "GowunBatang-Bold", size: 14)
    label.textColor = UIColor(named: "OrangeMainColor")
    label.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    accessoryType = .disclosureIndicator
    configureLayout()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureLayout() {
    let nameRow = UIStackView(arrangedSubviews: [cafeNameLabel, distanceLabel])
    nameRow.axis = .horizontal
    nameRow.translatesAutoresizingMaskIntoConstraints = false

    let textStack = UIStackView(arrangedSubviews: [nameRow, addressLabel])
    textStack.axis = .vertical
    textStack.distribution = .fillEqually
    textStack.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(cafeImageView)
    contentView.addSubview(textStack)

    NSLayoutConstraint.activate([
      cafeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
      cafeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
      cafeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
      cafeImageView.widthAnchor.constraint(equalTo: cafeImageView.heightAnchor),

      textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
      textStack.leadingAnchor.constraint(equalTo: cafeImageView.trailingAnchor, constant: 10),
      textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
      textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
    ])
  }

  func cellConfigure(row: NearCafeEntity) {
    cafeNameLabel.text = row.name
    addressLabel.text = row.address
    distanceLabel.text = "\(row.distance)m"
  }
}
