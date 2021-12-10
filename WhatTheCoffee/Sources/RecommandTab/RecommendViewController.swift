//
//  RecommendViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit
import FirebaseAnalytics

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
    
    configure()
    fetchData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Analytics.logEvent("TAB_recommend", parameters: nil)
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
    
    if let coffee = todayCoffee {
      if coffeeList.contains(coffee) {
        todayCoffeeImage.image = loadImageFromDocumentDirectory(type: .coffee, imageName: "coffee_\(coffee._id).jpg")
      } else {
        todayCoffee = nil
        todayCoffeeImage.image = UIImage.randomCoffeeImage
        todayCoffeeLabel.text = "오늘의 커피를\n목록에서 삭제하셨어요🥲\n다시 추천 받아보세요!"
      }
    } else {
      todayCoffeeImage.image = UIImage.randomCoffeeImage
      todayCoffeeLabel.text = "오늘의 커피를 추천받으세요!"
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
  
  @IBAction func onInfo(_ sender: UIBarButtonItem) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "settingVC") as! SettingViewController
    guard let env = environment else { return }
    vc.environment = env
    
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    self.present(nav, animated: true, completion: nil)
  }
  
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
    recommendButton.setTitle("다시 추천 받기", for: .normal)
    
    if !coffeeList.isEmpty {
      let randomCoffee = randomCoffee()
      
      todayCoffeeImage.image = loadImageFromDocumentDirectory(type: .coffee, imageName: "coffee_\(randomCoffee._id).jpg") ?? UIImage.randomCoffeeImage
      todayCoffeeLabel.text = randomCoffee.name
      todayCoffeeLabel.font = UIFont.GowunBatang(type: .regular, size: 15)
      
      todayCoffee = randomCoffee
    } else {
      showErrorAlert("커피 리스트가 비어있습니다.\n커피 목록에서 추가해주세요!")
    }
  }
}
