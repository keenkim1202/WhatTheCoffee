//
//  RecommendViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit

// TODO: 일단 기능 구현해서 완성하는게 우선!! 다 만들고 나서 분리하고 정리하기...
// TODO: coffee, cafe 이미지 저장 폴더 나누기도 나중에.

class RecommendViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  var todayCoffee: Coffee?
  var coffeeList: [Coffee] = []
  let buttonCornerRadius: CGFloat = 25
  
  // MARK: - UI
  @IBOutlet weak var todayCoffeeImage: UIImageView!
  @IBOutlet weak var todayCoffeeLabel: UILabel!
  @IBOutlet weak var recommendButton: UIButton!
  @IBOutlet weak var introduceLabel: UILabel!
  @IBOutlet weak var emptyView: UIView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    checkIsFirst()
    configure()
    fetchData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    fetchData()
    checkIsEmpty()
  }
  
  func checkIsEmpty() {
    if coffeeList.isEmpty {
      emptyView.isHidden = false
    } else {
      emptyView.isHidden = true
    }
  }

  // MARK: - Configure
  func configure() {
    recommendButton.layer.cornerRadius = buttonCornerRadius
    recommendButton.tintColor = UIColor.greenMainColor
    recommendButton.titleLabel?.textColor = UIColor.oppositeColor
  }
  
  func fetchData() {
    guard let env = environment else { return }
    coffeeList = env.coffeeRepository.fetch()
    
    // 기본 이미지로 변경하기
    todayCoffeeImage.image = UIImage(named: "random")!
    todayCoffeeLabel.text = ""
    introduceLabel.isHidden = false
    introduceLabel.text = "오늘의 커피를 추천 받아보세요!"
  }
  
  func checkIsFirst() {
    let isFirst = Storage.isFirstTime()
    print("isFirst = \(isFirst)")
    if isFirst == true {
      guard let env = environment else { return }
      let defaultCoffeeList: [String] = ["아메리카노", "에스프레소", "라떼", "바닐라라떼", "녹차라떼", "카페모카", "카라멜마끼아또"]
      for i in 0..<defaultCoffeeList.count {
        let coffee = Coffee(name: defaultCoffeeList[i])
        env.coffeeRepository.add(item: coffee)
        
        let image = UIImage(named: defaultCoffeeList[i]) ?? UIImage(named: "random")
        saveImageToDocumentDirectory(type: .coffee, imageName: "coffee_\(coffee._id).jpg", image: image!)
      }
      
      let defaultCafeList: [String] = ["cafe3", "cafe2", "cafe1"]
      for i in 0..<defaultCafeList.count {
        let cafe = Cafe(name: defaultCafeList[i], comment: "디저트가 매우 맛있음! (특히 당근케이크)", rate: 5 - i)
        env.cafeRepository.add(item: cafe)
        
        let image = UIImage(named: defaultCafeList[i]) ?? UIImage(named: "cafeDefault3")
        saveImageToDocumentDirectory(type: .cafe, imageName: "cafe_\(cafe._id).jpg", image: image!)
      }
    }
  }

  func randomCoffee() -> Coffee {
    var flag: Bool = false
    var index = Int.random(in: 0..<coffeeList.count)
    var randomCoffee = coffeeList[index]
    
    if coffeeList.count == 1 {
      return coffeeList[0]
    }
    
    if todayCoffee == nil {
      todayCoffeeImage.image = loadImageFromDocumentDirectory(type: .coffee, imageName: "coffee_\(randomCoffee._id).jpg")
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
  @IBAction func onCoffeeList(_ sender: UIBarButtonItem) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "coffeeListVC") as! CoffeeListViewController
    guard let env = environment else { return }
    vc.environment = env

    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    self.present(nav, animated: true, completion: nil)
  }
  
  /// component
  @IBAction func onRecommend(_ sender: UIButton) {
    introduceLabel.isHidden = true
    
    if !coffeeList.isEmpty {
      let randomCoffee = randomCoffee()
      
      todayCoffeeImage.image = loadImageFromDocumentDirectory(type: .coffee, imageName: "coffee_\(randomCoffee._id).jpg") ?? UIImage(named: "random")
      todayCoffeeLabel.text = randomCoffee.name
      todayCoffee = randomCoffee
      
    } else {
      showAlert("커피 리스트가 비어있습니다.\n커피 목록에서 추가해주세요!")
    }
  }
  
}
