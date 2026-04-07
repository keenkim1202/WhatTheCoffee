import UIKit

final class RecordSearchViewModel {

  // MARK: - Properties
  private let cafeRepository: CafeRepositoryProtocol
  private let imageManager = ImageManager.shared

  var results: [CafeEntity] = []

  // MARK: - Binding
  var onResultsUpdated: (() -> Void)?

  // MARK: - Init
  init(cafeRepository: CafeRepositoryProtocol) {
    self.cafeRepository = cafeRepository
  }

  // MARK: - Data
  var isEmpty: Bool {
    return results.isEmpty
  }

  var count: Int {
    return results.count
  }

  func cafe(at index: Int) -> CafeEntity {
    return results[index]
  }

  func cafeImage(at index: Int) -> UIImage {
    let cafe = results[index]
    return imageManager.loadImage(type: .cafe, imageName: "cafe_\(cafe.id).jpg") ?? UIImage.defaultCafeImage
  }

  func search(query: String) {
    results = cafeRepository.search(query: query)
    onResultsUpdated?()
  }
}
