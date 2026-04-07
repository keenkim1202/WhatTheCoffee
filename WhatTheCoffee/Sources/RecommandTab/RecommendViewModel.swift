import UIKit

final class RecommendViewModel {

  // MARK: - Properties
  private let useCase: RecommendCoffeeUseCase
  private let imageUseCase: ManageImageUseCase

  var coffeeList: [CoffeeEntity] = []
  var todayCoffee: CoffeeEntity?

  // MARK: - Binding
  var onCoffeeListUpdated: (() -> Void)?
  var onTodayCoffeeChanged: ((String?, UIImage?) -> Void)?

  // MARK: - Init
  init(useCase: RecommendCoffeeUseCase, imageUseCase: ManageImageUseCase) {
    self.useCase = useCase
    self.imageUseCase = imageUseCase
  }

  // MARK: - Data
  var isEmpty: Bool { coffeeList.isEmpty }

  func fetchData() {
    coffeeList = useCase.fetchAll()

    if let coffee = todayCoffee {
      if coffeeList.contains(coffee) {
        let image = imageUseCase.loadCoffeeImage(id: coffee.id)
        onTodayCoffeeChanged?(coffee.name, image)
      } else {
        todayCoffee = nil
        onTodayCoffeeChanged?("오늘의 커피를\n목록에서 삭제하셨어요🥲\n다시 추천 받아보세요!", UIImage.randomCoffeeImage)
      }
    } else {
      onTodayCoffeeChanged?("오늘의 커피를 추천받으세요!", UIImage.randomCoffeeImage)
    }

    onCoffeeListUpdated?()
  }

  func recommend() -> (name: String, image: UIImage?)? {
    guard let randomCoffee = useCase.pickRandom(from: coffeeList, excluding: todayCoffee) else { return nil }
    todayCoffee = randomCoffee
    let image = imageUseCase.loadCoffeeImage(id: randomCoffee.id) ?? UIImage.randomCoffeeImage
    return (randomCoffee.name, image)
  }
}
