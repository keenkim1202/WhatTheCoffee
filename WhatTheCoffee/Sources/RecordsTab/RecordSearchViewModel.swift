import UIKit

final class RecordSearchViewModel {

  // MARK: - Properties
  private let cafeRepository: CafeRepositoryType
  private let imageManager = ImageManager.shared

  var results: [Cafe] = []

  // MARK: - Binding
  var onResultsUpdated: (() -> Void)?

  // MARK: - Init
  init(cafeRepository: CafeRepositoryType) {
    self.cafeRepository = cafeRepository
  }

  // MARK: - Data
  var isEmpty: Bool {
    return results.isEmpty
  }

  var count: Int {
    return results.count
  }

  func cafe(at index: Int) -> Cafe {
    return results[index]
  }

  func cafeImage(at index: Int) -> UIImage {
    let cafe = results[index]
    return imageManager.loadImage(type: .cafe, imageName: "cafe_\(cafe._id).jpg") ?? UIImage.defaultCafeImage
  }

  func search(query: String) {
    results = cafeRepository.search(query: query)
    onResultsUpdated?()
  }
}
