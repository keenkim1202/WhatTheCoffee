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

  func cafeImage(at index: Int) -> UIImage {
    let cafe = results[index]
    return imageUseCase.loadCafeImage(id: cafe.id) ?? UIImage.defaultCafeImage
  }

  func search(query: String) {
    results = useCase.search(query: query)
    onResultsUpdated?()
  }
}
