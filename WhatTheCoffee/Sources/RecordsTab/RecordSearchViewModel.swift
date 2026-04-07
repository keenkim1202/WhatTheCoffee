import UIKit

final class RecordSearchViewModel {

  // MARK: - Properties
  private let useCase: ManageRecordsUseCase
  private let imageManager = ImageManager.shared

  var results: [CafeEntity] = []

  // MARK: - Binding
  var onResultsUpdated: (() -> Void)?

  // MARK: - Init
  init(useCase: ManageRecordsUseCase) {
    self.useCase = useCase
  }

  // MARK: - Data
  var isEmpty: Bool { results.isEmpty }
  var count: Int { results.count }

  func cafe(at index: Int) -> CafeEntity {
    return results[index]
  }

  func cafeImage(at index: Int) -> UIImage {
    let cafe = results[index]
    return imageManager.loadImage(type: .cafe, imageName: "cafe_\(cafe.id).jpg") ?? UIImage.defaultCafeImage
  }

  func search(query: String) {
    results = useCase.search(query: query)
    onResultsUpdated?()
  }
}
