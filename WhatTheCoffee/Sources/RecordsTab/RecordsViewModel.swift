import UIKit

final class RecordsViewModel {

  // MARK: - Properties
  private let useCase: ManageRecordsUseCase
  private let imageUseCase: ManageImageUseCase

  var cafeList: [CafeEntity] = []

  // MARK: - Binding
  var onCafeListUpdated: (() -> Void)?

  // MARK: - Init
  init(useCase: ManageRecordsUseCase, imageUseCase: ManageImageUseCase) {
    self.useCase = useCase
    self.imageUseCase = imageUseCase
  }

  // MARK: - Data
  var isEmpty: Bool { cafeList.isEmpty }
  var count: Int { cafeList.count }

  func cafe(at index: Int) -> CafeEntity {
    return cafeList[index]
  }

  func cafeImage(at index: Int) -> UIImage {
    let cafe = cafeList[index]
    return imageUseCase.loadCafeImage(id: cafe.id) ?? UIImage.defaultCafeImage
  }

  func fetchData() {
    cafeList = useCase.fetchAll()
    onCafeListUpdated?()
  }

  func deleteRecords(at indexPaths: [IndexPath]) {
    for i in indexPaths.sorted(by: { $0.item > $1.item }) {
      let item = cafeList[i.item]
      imageUseCase.deleteCafeImage(id: item.id)
      useCase.remove(id: item.id)
    }
    fetchData()
  }
}
