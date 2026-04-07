import UIKit

final class RecommendViewModel {

  // MARK: - Properties
  private let coffeeRepository: CoffeeRepositoryType
  private let imageManager = ImageManager.shared

  var coffeeList: [Coffee] = []
  var todayCoffee: Coffee?

  // MARK: - Binding
  var onCoffeeListUpdated: (() -> Void)?
  var onTodayCoffeeChanged: ((String?, UIImage?) -> Void)?

  // MARK: - Init
  init(coffeeRepository: CoffeeRepositoryType) {
    self.coffeeRepository = coffeeRepository
  }

  // MARK: - Data
  var isEmpty: Bool {
    return coffeeList.isEmpty
  }

  func fetchData() {
    coffeeList = coffeeRepository.fetch()

    if let coffee = todayCoffee {
      if coffeeList.contains(coffee) {
        let image = imageManager.loadImage(type: .coffee, imageName: "coffee_\(coffee._id).jpg")
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
    guard !coffeeList.isEmpty else { return nil }

    let randomCoffee = pickRandomCoffee()
    todayCoffee = randomCoffee

    let image = imageManager.loadImage(type: .coffee, imageName: "coffee_\(randomCoffee._id).jpg") ?? UIImage.randomCoffeeImage
    return (randomCoffee.name, image)
  }

  private func pickRandomCoffee() -> Coffee {
    if coffeeList.count == 1 {
      return coffeeList[0]
    }

    guard let current = todayCoffee else {
      return coffeeList[Int.random(in: 0..<coffeeList.count)]
    }

    var index = Int.random(in: 0..<coffeeList.count)
    while coffeeList[index].name == current.name {
      index = Int.random(in: 0..<coffeeList.count)
    }
    return coffeeList[index]
  }
}
