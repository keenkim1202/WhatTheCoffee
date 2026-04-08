import UIKit

class RecordCollectionViewCell: UICollectionViewCell {

  static let identifier = "recordCell"

  let backgroundImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleToFill
    iv.clipsToBounds = true
    iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()

  private let dimView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  let nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label.textColor = .white
    label.shadowColor = .black
    label.shadowOffset = CGSize(width: 1, height: 1)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  let dateLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "GowunBatang-Bold", size: 12)
    label.textColor = .white
    label.shadowColor = .black
    label.shadowOffset = CGSize(width: 1, height: 1)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  let rateImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()

  let highlightView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 1, alpha: 0.85)
    view.isHidden = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  let checkImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(systemName: "checkmark.circle.fill")
    iv.tintColor = .systemGreen
    iv.preferredSymbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
    iv.isHidden = true
    iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()

  override var isHighlighted: Bool {
    didSet {
      highlightView.isHidden = !isHighlighted
    }
  }

  override var isSelected: Bool {
    didSet {
      highlightView.isHidden = !isSelected
      checkImageView.isHidden = !isSelected
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureLayout()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureLayout() {
    layer.cornerRadius = 8
    clipsToBounds = true

    let textStack = UIStackView(arrangedSubviews: [nameLabel, dateLabel])
    textStack.axis = .vertical
    textStack.alignment = .center
    textStack.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(backgroundImageView)
    contentView.addSubview(dimView)
    contentView.addSubview(textStack)
    contentView.addSubview(rateImageView)
    contentView.addSubview(highlightView)
    contentView.addSubview(checkImageView)

    NSLayoutConstraint.activate([
      backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

      dimView.topAnchor.constraint(equalTo: contentView.topAnchor),
      dimView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      dimView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      dimView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

      textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
      textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
      textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

      nameLabel.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
      nameLabel.trailingAnchor.constraint(equalTo: textStack.trailingAnchor),
      dateLabel.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
      dateLabel.trailingAnchor.constraint(equalTo: textStack.trailingAnchor),

      rateImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
      rateImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
      rateImageView.widthAnchor.constraint(equalToConstant: 50),
      rateImageView.heightAnchor.constraint(equalToConstant: 50),

      highlightView.topAnchor.constraint(equalTo: contentView.topAnchor),
      highlightView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      highlightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      highlightView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

      checkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
      checkImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
      checkImageView.widthAnchor.constraint(equalTo: checkImageView.heightAnchor)
    ])
  }

  func cellConfigure(with item: CafeEntity) {
    nameLabel.text = item.name
    rateImageView.image = UIImage(named: "star\(item.rate)")!
    dateLabel.text = DateFormatter.visitDateFormat.string(from: item.visitDate)
  }
}
