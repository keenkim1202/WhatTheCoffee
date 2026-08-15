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

  /// 그 기록에서 마신 커피 사진. 커피를 지웠으면 사진도 없어 nil이 된다.
  func coffeeImage(at index: Int) -> UIImage? {
    guard let id = cafeList[index].coffeeId else { return nil }
    return imageUseCase.loadCoffeeImage(id: id)
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
