import UIKit

/// 처음 실행할 때 넣어주는 기본 커피·카페와, 설정에서 다시 넣는 기능.
/// 화면이 Repository를 직접 만지던 자리를 대신한다.
final class ManageDefaultDataUseCase {

  private let coffeeRepository: CoffeeRepositoryProtocol
  private let cafeRepository: CafeRepositoryProtocol
  private let imageUseCase: ManageImageUseCase

  init(coffeeRepository: CoffeeRepositoryProtocol,
       cafeRepository: CafeRepositoryProtocol,
       imageUseCase: ManageImageUseCase) {
    self.coffeeRepository = coffeeRepository
    self.cafeRepository = cafeRepository
    self.imageUseCase = imageUseCase
  }

  /// 첫 실행이면 기본 데이터를 한 번 넣는다.
  /// isFirstTime()은 읽으면서 표시까지 남기므로 두 번 불러선 안 된다.
  func installDefaultsIfNeeded() {
    guard Storage.isFirstTime() else { return }
    addDefaultIceCoffees()
    addDefaultHotCoffees()
    addDefaultCafes()
  }

  func addDefaultIceCoffees() {
    CoffeeNameList.defaultIceCoffeeList.forEach { addCoffee(assetNamed: $0) }
  }

  func addDefaultHotCoffees() {
    CoffeeNameList.defaultHotCoffeeList.forEach { addCoffee(assetNamed: $0) }
  }

  /// 에셋 이름이 곧 커피 이름이다. 밑줄은 화면에 보일 때 띄어쓰기가 된다.
  func addCoffee(assetNamed asset: String) {
    let name = asset.replacingOccurrences(of: "_", with: " ")
    let coffee = coffeeRepository.add(name: name)
    imageUseCase.saveCoffeeImage(id: coffee.id, image: UIImage(named: asset) ?? UIImage.randomCoffeeImage)
  }

  private func addDefaultCafes() {
    let assets = ["합정_오츠커피", "대부도_엔틸로프", "송도_컵피"]
    let comments = [
      "아인슈페너 맛집",
      "라떼 맛집으로 소문남",
      "카페 분위기를 중요시하는 사람이라면 필수 방문"
    ]

    for (index, asset) in assets.enumerated() {
      let name = asset.replacingOccurrences(of: "_", with: " ")
      let cafe = cafeRepository.add(
        name: name,
        visitDate: Date(),
        comment: comments[index],
        rate: 5 - index)

      imageUseCase.saveCafeImage(id: cafe.id, image: UIImage(named: asset) ?? UIImage.defaultCafeImage)
    }
  }
}
