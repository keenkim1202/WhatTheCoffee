import UIKit

class RecordCollectionViewCell: UICollectionViewCell {
  
  static let identifier = "recordCell"
  
  @IBOutlet weak var cellView: UIView!
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var rateImageView: UIImageView!
  @IBOutlet weak var checkImageView: UIImageView!
  @IBOutlet weak var highlightView: UIView!
  
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
  
  func cellConfigure(with item: CafeEntity) {
    self.layer.cornerRadius = CGFloat(8)
    self.clipsToBounds = true
    
    nameLabel.text = item.name
    rateImageView.image = UIImage(named: "star\(item.rate)")!
    dateLabel.text = DateFormatter.visitDateFormat.string(from: item.visitDate)
  }
}
