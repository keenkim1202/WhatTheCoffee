import UIKit

final class RecordsViewModel {

  // MARK: - Properties
  private let cafeRepository: CafeRepositoryProtocol
  private let imageManager = ImageManager.shared

  var cafeList: [CafeEntity] = []

  // MARK: - Binding
  var onCafeListUpdated: (() -> Void)?

  // MARK: - Init
  init(cafeRepository: CafeRepositoryProtocol) {
    self.cafeRepository = cafeRepository
  }

  // MARK: - Data
  var isEmpty: Bool {
    return cafeList.isEmpty
  }

  var count: Int {
    return cafeList.count
  }

  func cafe(at index: Int) -> CafeEntity {
    return cafeList[index]
  }

  func cafeImage(at index: Int) -> UIImage {
    let cafe = cafeList[index]
    return imageManager.loadImage(type: .cafe, imageName: "cafe_\(cafe.id).jpg") ?? UIImage.defaultCafeImage
  }

  func fetchData() {
    cafeList = cafeRepository.fetch()
    onCafeListUpdated?()
  }

  func deleteRecords(at indexPaths: [IndexPath]) {
    for i in indexPaths.sorted(by: { $0.item > $1.item }) {
      let item = cafeList[i.item]
      imageManager.deleteImage(type: .cafe, imageName: "cafe_\(item.id).jpg")
      cafeRepository.remove(id: item.id)
    }
    fetchData()
  }
}
