import UIKit

final class AddRecordViewModel {

  enum ViewType {
    case add
    case update
  }

  // MARK: - Properties
  private let cafeRepository: CafeRepositoryType
  private let imageManager = ImageManager.shared

  let viewType: ViewType
  let cafe: Cafe?
  var rate: Int?

  // MARK: - Init
  init(cafeRepository: CafeRepositoryType, cafe: Cafe? = nil) {
    self.cafeRepository = cafeRepository
    self.cafe = cafe
    self.viewType = cafe != nil ? .update : .add
    self.rate = cafe?.rate
  }

  // MARK: - Data
  var navigationTitle: String {
    return viewType == .update ? "기록 수정" : "기록 추가"
  }

  var currentImage: UIImage {
    if let cafe = cafe {
      return imageManager.loadImage(type: .cafe, imageName: "cafe_\(cafe._id).jpg") ?? UIImage.defaultCafeImage
    }
    return UIImage.defaultCafeImage
  }

  var currentName: String? {
    return cafe?.name
  }

  var currentDate: String? {
    guard let cafe = cafe else { return nil }
    return DateFormatter.selectDateFormat.string(from: cafe.visitDate)
  }

  var currentComment: String? {
    return cafe?.comment
  }

  var currentRate: Rate? {
    guard let cafe = cafe else { return nil }
    return Rate(rawValue: cafe.rate)
  }

  func save(name: String, visitDateString: String?, comment: String?, image: UIImage?) {
    guard let rate = rate else { return }

    var item = Cafe(name: name, comment: comment, rate: rate)

    if let dateString = visitDateString, let date = DateFormatter.selectDateFormat.date(from: dateString) {
      item = Cafe(name: name, visitDate: date, comment: comment, rate: rate)
    }

    if viewType == .update, let cafe = cafe {
      cafeRepository.update(item: cafe, new: item)

      if let image = image, image != UIImage.defaultCafeImage {
        imageManager.saveImage(type: .cafe, imageName: "cafe_\(cafe._id).jpg", image: image)
      } else {
        let previousImage = imageManager.loadImage(type: .cafe, imageName: "cafe_\(cafe._id).jpg")
        if previousImage != nil {
          imageManager.deleteImage(type: .cafe, imageName: "cafe_\(cafe._id).jpg")
        }
      }
    } else {
      cafeRepository.add(item: item)

      if let image = image, image != UIImage.defaultCafeImage {
        imageManager.saveImage(type: .cafe, imageName: "cafe_\(item._id).jpg", image: image)
      }
    }
  }
}
