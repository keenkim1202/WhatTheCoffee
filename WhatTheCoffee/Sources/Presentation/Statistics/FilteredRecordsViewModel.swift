import UIKit

final class FilteredRecordsViewModel {

  private let filter: RecordFilter
  private let useCase: ManageRecordsUseCase
  private let imageUseCase: ManageImageUseCase

  private var records: [CafeEntity] = []

  /// 카드의 커피 스티커는 50pt다. 원본을 읽으면 셀을 넘길 때마다 큰 비트맵을 만든다.
  private static let stickerPixelSize: CGFloat = 150

  init(filter: RecordFilter, useCase: ManageRecordsUseCase, imageUseCase: ManageImageUseCase) {
    self.filter = filter
    self.useCase = useCase
    self.imageUseCase = imageUseCase
    reload()
  }

  // MARK: - Data
  var title: String { filter.title }
  var summary: String { filter.summary(count: records.count) }
  var isEmpty: Bool { records.isEmpty }
  var count: Int { records.count }

  func reload() {
    records = useCase.fetchAll().filter { filter.matches($0) }
  }

  func cafe(at index: Int) -> CafeEntity {
    return records[index]
  }

  func cafeImage(at index: Int) -> UIImage {
    return imageUseCase.loadCafeImage(id: records[index].id) ?? UIImage.defaultCafeImage
  }

  func coffeeImage(at index: Int) -> UIImage? {
    guard let id = records[index].coffeeId else { return nil }
    return imageUseCase.loadCoffeeImage(id: id, maxPixelSize: Self.stickerPixelSize)?.roundedCorners()
  }
}
