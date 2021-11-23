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
  }
  
  func checkIsFirst() { // 최초 실행이면 기본 커피 리스트 추가하기
    let isFirst = Storage.isFirstTime()
    print("isFirst = \(isFirst)")
    if isFirst == true {
      guard let env = environment else {
        print("env nil.")
        return
      }
      let defaultCoffeeList: [String] = ["아메리카노", "에스프레소", "라떼", "바닐라라떼", "녹차라떼", "카페모카"]
      for i in 0..<defaultCoffeeList.count {
        let coffee = Coffee(name: defaultCoffeeList[i])
        env.coffeeRepository.add(item: coffee)
        
        let image = UIImage(named: defaultCoffeeList[i]) ?? UIImage(named: "random_coffee_image")
        saveImageToDocumentDirectory(imageName: "\(coffee._id).jpg", image: image!)
      }
    }
  }
  
  // MARK: Configuring Alert
  fileprivate func showAlert(_ message: String) {
    UIAlertController
      .show(self, contentType: .error, message: message)
  }
  
  // MARK: - Actions
  /// barButtonItems
  @IBAction func coffeeListBarButton(_ sender: UIBarButtonItem) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "coffeeListVC") as! CoffeeListViewController
    guard let env = environment else { return }
    vc.coffeeList = env.coffeeRepository.fetch()

    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    self.present(nav, animated: true, completion: nil)
  }
  
  /// component
  @IBAction func onRecommend(_ sender: UIButton) {
    guard let env = environment else { return }
    let coffeeList = env.coffeeRepository.fetch()
    
    if !coffeeList.isEmpty {
      let randomCoffee = coffeeList.randomElement()!
      todayCoffeeImage.image = loadImageFromDocumentDirectory(imageName: "\(randomCoffee._id).jpg")
      todayCoffeeLabel.text = randomCoffee.name
    } else {
      showAlert("커피 리스트가 비어있습니다.\n커피 목록에서 추가해주세요!")
    }
    
    
  }
  
}
