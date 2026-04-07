import UIKit

final class RecommendViewModel {

  // MARK: - Properties
  private let useCase: RecommendCoffeeUseCase
  private let imageManager = ImageManager.shared

  var coffeeList: [CoffeeEntity] = []
  var todayCoffee: CoffeeEntity?

  // MARK: - Binding
  var onCoffeeListUpdated: (() -> Void)?
  var onTodayCoffeeChanged: ((String?, UIImage?) -> Void)?

  // MARK: - Init
  init(useCase: RecommendCoffeeUseCase) {
    self.useCase = useCase
  }

  // MARK: - Data
  var isEmpty: Bool {
    return coffeeList.isEmpty
  }

  func fetchData() {
    coffeeList = useCase.fetchAll()

    if let coffee = todayCoffee {
      if coffeeList.contains(coffee) {
        let image = imageManager.loadImage(type: .coffee, imageName: "coffee_\(coffee.id).jpg")
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

    let image = imageManager.loadImage(type: .coffee, imageName: "coffee_\(randomCoffee.id).jpg") ?? UIImage.randomCoffeeImage
    return (randomCoffee.name, image)
  }
}
