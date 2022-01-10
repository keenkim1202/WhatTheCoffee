//
//  AddDefaultImageViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2022/01/10.
//

import UIKit

class AddDefaultImageViewController: BaseViewController {
  
  // MARK: - Property
  var environment: Environment? = nil
  
  // MARK: - UI
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
      
    configure()
  }
  
  // MARK: - Configure
  func configure() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  // MARK: - Action
  @IBAction func onClose(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
}

// MARK: - Extension
extension AddDefaultImageViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return CoffeeNameList.defaultIceCoffeeList.count
    } else {
      return CoffeeNameList.defaultHotCoffeeList.count
    }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "아이스 음료 목록"
    } else {
      return "따뜻한 음료 목록"
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: AddDefaultImageTableViewCell.identifier) as? AddDefaultImageTableViewCell else { return UITableViewCell() }
    
    if indexPath.section == 0 {
      let iceCoffee = CoffeeNameList.defaultIceCoffeeList[indexPath.row]
      let image = UIImage(named: iceCoffee) ?? UIImage.randomCoffeeImage
      
      cell.coffeeImageView.image = image
      cell.nameLabel.text = iceCoffee.replacingOccurrences(of: "_", with: " ")
    } else {
      let hotCoffee = CoffeeNameList.defaultHotCoffeeList[indexPath.row]
      let image = UIImage(named: hotCoffee) ?? UIImage.randomCoffeeImage
      
      cell.coffeeImageView.image = image
      cell.nameLabel.text = hotCoffee.replacingOccurrences(of: "_", with: " ")
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let env = environment {
      if indexPath.section == 0 {
        let iceCoffee = CoffeeNameList.defaultIceCoffeeList[indexPath.row]
        let image = UIImage(named: iceCoffee) ?? UIImage.randomCoffeeImage
        let name = iceCoffee.replacingOccurrences(of: "_", with: " ")
        
        self.addAlert("다음 커피를 추가하시겠습니까?", name) {
          let coffee = Coffee(name: name)
          env.coffeeRepository.add(item: coffee)
          
          self.saveImageToDocumentDirectory(type: .coffee, imageName: "coffee_\(coffee._id).jpg", image: image)
          self.showSuccessAlert("재추가에 성공하였습니다.")
        }
      } else {
        let hotCoffee = CoffeeNameList.defaultHotCoffeeList[indexPath.row]
        let image = UIImage(named: hotCoffee) ?? UIImage.randomCoffeeImage
        let name = hotCoffee.replacingOccurrences(of: "_", with: " ")
        
        self.addAlert("다음 커피를 추가하시겠습니까?", name) {
          let coffee = Coffee(name: name)
          env.coffeeRepository.add(item: coffee)
          
          self.saveImageToDocumentDirectory(type: .coffee, imageName: "coffee_\(coffee._id).jpg", image: image)
          self.showSuccessAlert("재추가에 성공하였습니다.")
        }
      }
    } else {
      self.showErrorAlert("재추가에 실패하였습니다.")
    }
  }
}
