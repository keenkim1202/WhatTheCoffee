//
//  RecommendViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit

class RecommendViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  var todayCoffee: Coffee?
  var coffeeList: [Coffee] = []
  
  // MARK: - UI
  @IBOutlet weak var todayCoffeeImage: UIImageView!
  @IBOutlet weak var todayCoffeeLabel: UILabel!
  @IBOutlet weak var recommendButton: UIButton!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    checkIsFirst()
    configure()
  }

  // MARK: - Configure
  func configure() {
    recommendButton.tintColor = UIColor.recommendButtonColor
    recommendButton.titleLabel?.textColor = UIColor.oppositeColor
    
    guard let env = environment else { return }
    coffeeList = env.coffeeRepository.fetch()
  }
  
  func checkIsFirst() { // 최초 실행이면 기본 커피 리스트 추가하기
    let isFirst = Storage.isFirstTime()
    print("isFirst = \(isFirst)")
    if isFirst == true {
      guard let env = environment else {
        print("env nil.")
        return
      }
      let defaultCoffeeList: [String] = ["아메리카노", "에스프레소", "라떼", "바닐라라떼", "녹차라떼", "카페모카", "카라멜마끼아또"]
      for i in 0..<defaultCoffeeList.count {
        let coffee = Coffee(name: defaultCoffeeList[i])
        env.coffeeRepository.add(item: coffee)
        
        let image = UIImage(named: defaultCoffeeList[i]) ?? UIImage(named: "random")
        saveImageToDocumentDirectory(imageName: "\(coffee._id).jpg", image: image!)
      }
    }
  }

  func randomCoffee() -> Coffee {
    var flag: Bool = false
    var index = Int.random(in: 0..<coffeeList.count)
    var randomCoffee = coffeeList[index]
    
    if todayCoffee == nil {
      todayCoffeeImage.image = loadImageFromDocumentDirectory(imageName: "\(randomCoffee._id).jpg")
      todayCoffeeLabel.text = randomCoffee.name
      return randomCoffee
    }
    
    while flag == false {
      if let coffee = todayCoffee {
        if coffee.name == randomCoffee.name {
          index = Int.random(in: 0..<coffeeList.count)
          randomCoffee = coffeeList[index]
        } else {
          flag = true
        }
      }
    }
    return randomCoffee
  }
  
  // MARK: - Actions
  /// barButtonItems
  @IBAction func coffeeListBarButton(_ sender: UIBarButtonItem) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "coffeeListVC") as! CoffeeListViewController
    guard let env = environment else { return }
    vc.environment = env
    vc.coffeeList = env.coffeeRepository.fetch()

    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    self.present(nav, animated: true, completion: nil)
  }
  
  /// component
  @IBAction func onRecommend(_ sender: UIButton) {
    // TODO: Alert를 띄울지, 아니면 화면에 이미지와 텍스트를 지우고 '커피목록이 비어있습니다'를 출력해줄지 고민중...
    if !coffeeList.isEmpty {
      let randomCoffee = randomCoffee()
      
      todayCoffeeImage.image = loadImageFromDocumentDirectory(imageName: "\(randomCoffee._id).jpg") ?? UIImage(named: "random")
      todayCoffeeLabel.text = randomCoffee.name
      todayCoffee = randomCoffee
      
    } else {
      showAlert("커피 리스트가 비어있습니다.\n커피 목록에서 추가해주세요!")
    }
  }
  
}
