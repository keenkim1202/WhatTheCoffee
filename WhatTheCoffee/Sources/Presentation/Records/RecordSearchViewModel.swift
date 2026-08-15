import UIKit

final class RecordSearchViewModel {

  // MARK: - Properties
  private let useCase: ManageRecordsUseCase
  private let imageUseCase: ManageImageUseCase

  var results: [CafeEntity] = []

  // MARK: - Binding
  var onResultsUpdated: (() -> Void)?

  // MARK: - Init
  init(useCase: ManageRecordsUseCase, imageUseCase: ManageImageUseCase) {
    self.useCase = useCase
    self.imageUseCase = imageUseCase
  }

  // MARK: - Data
  var isEmpty: Bool { results.isEmpty }
  var count: Int { results.count }

  func cafe(at index: Int) -> CafeEntity {
    return results[index]
  }

  /// 그 기록에서 마신 커피 사진. 목록과 검색 결과가 같은 셀을 쓰므로 여기도 필요하다.
  private static let stickerPixelSize: CGFloat = 150

  func coffeeImage(at index: Int) -> UIImage? {
    guard let id = results[index].coffeeId else { return nil }
    // 카드의 스티커는 50pt다. 원본을 읽으면 셀을 넘길 때마다 1024픽셀짜리를 펼치게 된다.
    return imageUseCase.loadCoffeeImage(id: id, maxPixelSize: Self.stickerPixelSize)?.roundedCorners()
  }

  func cafeImage(at index: Int) -> UIImage {
    let cafe = results[index]
    return imageUseCase.loadCafeImage(id: cafe.id) ?? UIImage.defaultCafeImage
  }

  func search(query: String) {
    results = useCase.search(query: query)
    onResultsUpdated?()
  }
}
