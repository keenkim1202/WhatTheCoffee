import UIKit

final class AddRecordViewModel {

  enum ViewType {
    case add
    case update
  }

  // MARK: - Properties
  private let cafeRepository: CafeRepositoryProtocol
  private let imageManager = ImageManager.shared

  let viewType: ViewType
  let cafe: CafeEntity?
  var rate: Int?

  // MARK: - Init
  init(cafeRepository: CafeRepositoryProtocol, cafe: CafeEntity? = nil) {
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
      return imageManager.loadImage(type: .cafe, imageName: "cafe_\(cafe.id).jpg") ?? UIImage.defaultCafeImage
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

    let visitDate: Date
    if let dateString = visitDateString, let date = DateFormatter.selectDateFormat.date(from: dateString) {
      visitDate = date
    } else {
      visitDate = Date()
    }

    if viewType == .update, let cafe = cafe {
      cafeRepository.update(id: cafe.id, name: name, visitDate: visitDate, comment: comment, rate: rate)

      if let image = image, image != UIImage.defaultCafeImage {
        imageManager.saveImage(type: .cafe, imageName: "cafe_\(cafe.id).jpg", image: image)
      } else {
        let previousImage = imageManager.loadImage(type: .cafe, imageName: "cafe_\(cafe.id).jpg")
        if previousImage != nil {
          imageManager.deleteImage(type: .cafe, imageName: "cafe_\(cafe.id).jpg")
        }
      }
    } else {
      let newCafe = cafeRepository.add(name: name, visitDate: visitDate, comment: comment, rate: rate)

      if let image = image, image != UIImage.defaultCafeImage {
        imageManager.saveImage(type: .cafe, imageName: "cafe_\(newCafe.id).jpg", image: image)
      }
    }
  }
}
