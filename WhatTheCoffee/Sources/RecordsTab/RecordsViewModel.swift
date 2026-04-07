import UIKit

final class RecordsViewModel {

  // MARK: - Properties
  private let useCase: ManageRecordsUseCase
  private let imageManager = ImageManager.shared

  var cafeList: [CafeEntity] = []

  // MARK: - Binding
  var onCafeListUpdated: (() -> Void)?

  // MARK: - Init
  init(useCase: ManageRecordsUseCase) {
    self.useCase = useCase
  }

  // MARK: - Data
  var isEmpty: Bool { cafeList.isEmpty }
  var count: Int { cafeList.count }

  func cafe(at index: Int) -> CafeEntity {
    return cafeList[index]
  }

  func cafeImage(at index: Int) -> UIImage {
    let cafe = cafeList[index]
    return imageManager.loadImage(type: .cafe, imageName: "cafe_\(cafe.id).jpg") ?? UIImage.defaultCafeImage
  }

  func fetchData() {
    cafeList = useCase.fetchAll()
    onCafeListUpdated?()
  }

  func deleteRecords(at indexPaths: [IndexPath]) {
    for i in indexPaths.sorted(by: { $0.item > $1.item }) {
      let item = cafeList[i.item]
      imageManager.deleteImage(type: .cafe, imageName: "cafe_\(item.id).jpg")
      useCase.remove(id: item.id)
    }
    fetchData()
  }
}
