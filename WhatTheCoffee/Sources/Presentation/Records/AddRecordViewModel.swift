import UIKit

final class AddRecordViewModel {

  enum ViewType {
    case add
    case update
  }

  // MARK: - Properties
  private let useCase: ManageRecordsUseCase
  private let imageUseCase: ManageImageUseCase

  let viewType: ViewType
  let cafe: CafeEntity?
  var rate: Int?
  var selectedLocation: SelectedLocation?

  // MARK: - Init
  init(useCase: ManageRecordsUseCase,
       imageUseCase: ManageImageUseCase,
       cafe: CafeEntity? = nil,
       prefilledLocation: SelectedLocation? = nil) {
    self.useCase = useCase
    self.imageUseCase = imageUseCase
    self.cafe = cafe
    self.viewType = cafe != nil ? .update : .add
    self.rate = cafe?.rate

    if let cafe, let lat = cafe.latitude, let lng = cafe.longitude {
      self.selectedLocation = SelectedLocation(
        name: cafe.name, address: cafe.address ?? "", latitude: lat, longitude: lng)
    } else {
      // 근처 카페에서 넘어온 경우. 기존 기록이 아니라 새 기록이므로 viewType은 .add 그대로다.
      self.selectedLocation = prefilledLocation
    }
  }

  // MARK: - Data
  var navigationTitle: String {
    return viewType == .update ? "기록 수정" : "기록 추가"
  }

  var currentImage: UIImage {
    if let cafe = cafe {
      return imageUseCase.loadCafeImage(id: cafe.id) ?? UIImage.defaultCafeImage
    }
    return UIImage.defaultCafeImage
  }

  var currentName: String? { cafe?.name ?? selectedLocation?.name }

  var currentDate: String? {
    guard let cafe = cafe else { return nil }
    return DateFormatter.selectDateFormat.string(from: cafe.visitDate)
  }

  var currentComment: String? { cafe?.comment }

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

    let lat = selectedLocation?.latitude
    let lng = selectedLocation?.longitude
    let address = selectedLocation?.address

    if viewType == .update, let cafe {
      useCase.update(id: cafe.id, name: name, visitDate: visitDate, comment: comment, rate: rate, latitude: lat, longitude: lng, address: address)

      if let image, image != UIImage.defaultCafeImage {
        imageUseCase.saveCafeImage(id: cafe.id, image: image)
      } else {
        if imageUseCase.loadCafeImage(id: cafe.id) != nil {
          imageUseCase.deleteCafeImage(id: cafe.id)
        }
      }
    } else {
      let newCafe = useCase.add(name: name, visitDate: visitDate, comment: comment, rate: rate, latitude: lat, longitude: lng, address: address)

      if let image, image != UIImage.defaultCafeImage {
        imageUseCase.saveCafeImage(id: newCafe.id, image: image)
      }
    }
  }
}
