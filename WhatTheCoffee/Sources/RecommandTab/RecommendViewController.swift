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
  let buttonCornerRadius: CGFloat = 20
  
  // MARK: - UI
  @IBOutlet weak var todayCoffeeImage: UIImageView!
  @IBOutlet weak var todayCoffeeLabel: UILabel!
  @IBOutlet weak var recommendButton: UIButton!
  @IBOutlet weak var emptyView: UIView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let env = environment {
      checkIsFirst(env: env)
    }
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
    adjustNavigationBarFont()
    
    todayCoffeeImage.layer.cornerRadius = CGFloat(5)
    recommendButton.layer.cornerRadius = buttonCornerRadius
    recommendButton.tintColor = UIColor.greenMainColor
    recommendButton.titleLabel?.textColor = UIColor.oppositeColor
  }
  
  func fetchData() {
    guard let env = environment else { return }
    coffeeList = env.coffeeRepository.fetch()
    
    todayCoffeeImage.image = UIImage.randomCoffeeImage
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
    if !coffeeList.isEmpty {
      let randomCoffee = randomCoffee()
      
      todayCoffeeImage.image = loadImageFromDocumentDirectory(type: .coffee, imageName: "coffee_\(randomCoffee._id).jpg") ?? UIImage.randomCoffeeImage
      todayCoffeeLabel.text = randomCoffee.name
      todayCoffeeLabel.font = UIFont.GowunBatang(type: .regular, size: 15)
      
      todayCoffee = randomCoffee
      
    } else {
      showAlert("커피 리스트가 비어있습니다.\n커피 목록에서 추가해주세요!")
    }
  }
}
