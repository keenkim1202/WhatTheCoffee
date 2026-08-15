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
  var visitCount: Int = 1
  var coffeeName: String?
  var coffeeId: String?
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
    self.visitCount = cafe?.visitCount ?? 1
    self.coffeeName = cafe?.coffeeName
    self.coffeeId = cafe?.coffeeId

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
    let dates = adjustedVisitDates(latest: keepingTime(of: visitDate))

    if viewType == .update, let cafe {
      useCase.update(id: cafe.id, name: name, visitDate: visitDate, comment: comment, rate: rate, latitude: lat, longitude: lng, address: address, visitDates: dates, coffeeName: coffeeName, coffeeId: coffeeId)

      if let image, image != UIImage.defaultCafeImage {
        imageUseCase.saveCafeImage(id: cafe.id, image: image)
      } else {
        if imageUseCase.loadCafeImage(id: cafe.id) != nil {
          imageUseCase.deleteCafeImage(id: cafe.id)
        }
      }
    } else {
      let newCafe = useCase.add(name: name, visitDate: visitDate, comment: comment, rate: rate, latitude: lat, longitude: lng, address: address, visitDates: dates, coffeeName: coffeeName, coffeeId: coffeeId)

      if let image, image != UIImage.defaultCafeImage {
        imageUseCase.saveCafeImage(id: newCafe.id, image: image)
      }
    }
  }

  /// 화면에서 고른 횟수와 날짜에 맞춰 방문 날짜 목록을 만든다.
  ///
  /// 규칙은 하나다. **화면의 날짜가 가장 최근 방문이다.**
  /// 이걸 지키지 않으면 목록에 뜨는 날짜, 정렬 기준, 통계가 서로 다른 날을 가리키게 된다.
  /// 그래서 고른 날짜보다 늦은 기존 방문은 남기지 않는다. 대신 총 횟수는 그대로 지킨다.
  ///
  /// 횟수를 줄이면 **첫 방문과 화면의 날짜를 남기고 그 사이부터 덜어낸다.**
  /// 가장 최근 방문을 지우면 위 규칙이 깨지고, 첫 방문을 지우면 언제부터 다닌 곳인지가 사라진다.
  private func adjustedVisitDates(latest: Date) -> [Date] {
    let count = max(1, visitCount)

    // 오래된 쪽부터 지킨다. 첫 방문이 언제였는지가 나중에 볼 때 쓸모 있다.
    let earlier = (cafe?.visitDates ?? []).filter { $0 < latest }.sorted()
    var dates = Array(earlier.prefix(count - 1))

    // 남길 게 모자라면 고른 날짜로 채운다. 알 수 없는 날을 지어내지 않는다.
    if dates.count < count - 1 {
      dates.append(contentsOf: Array(repeating: latest, count: count - 1 - dates.count))
    }

    dates.append(latest)
    return dates
  }

  /// 화면은 날짜만 고르게 되어 있어 시각이 자정으로 떨어진다.
  /// 같은 날이면 원래 시각을 지켜, 위젯으로 남긴 시간이 다른 항목을 고치다 지워지지 않게 한다.
  private func keepingTime(of picked: Date) -> Date {
    guard let previous = cafe?.visitDates.max(),
          Calendar.current.isDate(previous, inSameDayAs: picked) else { return picked }
    return previous
  }
}
