//
//  UIViewController++Extension.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/22.
//

import UIKit

// MARK: - Check is First
extension UIViewController {
  func checkIsFirst(env: Environment) {
    let isFirst = Storage.isFirstTime()
    print("isFirst = \(isFirst)")
    if isFirst == true {
      let defaultCoffeeList: [String] = ["아메리카노", "에스프레소", "라떼", "바닐라_라떼", "그린티_라떼", "모카_라떼", "카라멜_마끼아또"]
      for i in 0..<defaultCoffeeList.count {
        let coffee = Coffee(name: defaultCoffeeList[i].replacingOccurrences(of: "_", with: " "))
        env.coffeeRepository.add(item: coffee)
        
        let image = UIImage(named: defaultCoffeeList[i]) ?? UIImage.randomCoffeeImage
        saveImageToDocumentDirectory(type: .coffee, imageName: "coffee_\(coffee._id).jpg", image: image)
      }
      
      let defaultCafeList: [String] = ["합정_오츠커피", "대부도_엔틸로프", "송도_컵피"]
      let commentList: [String] = ["아인슈페너 맛집", "라떼 맛집으로 소문남", "카페 분위기를 중요시하는 사람이라면 필수 방문"]
      for i in 0..<defaultCafeList.count {
        let cafe = Cafe(name: defaultCafeList[i].replacingOccurrences(of: "_", with: " "), comment: commentList[i], rate: 5 - i)
        env.cafeRepository.add(item: cafe)
        
        let image = UIImage(named: defaultCafeList[i]) ?? UIImage.defaultCafeImage
        saveImageToDocumentDirectory(type: .cafe, imageName: "cafe_\(cafe._id).jpg", image: image)
      }
    }
  }
}

// MARK: - Configuring Alert
extension UIViewController {
  func showAlert(_ message: String) {
    UIAlertController
      .show(self, contentType: .error, message: message)
  }
  
  func errorAlert(error: AppError) {
    self.present(error.alert, animated: true, completion: nil)
  }
}

// MARK: - Delete Alert
extension UIViewController {
  typealias CompletionHandler = () -> Void
  
  func deleteAlert(_ message: String, completion: @escaping CompletionHandler) {
    let alert = UIAlertController(title: "⚠️", message: message, preferredStyle: .alert)
    let no = UIAlertAction(title: "아니오", style: .default, handler: nil)
    let yes = UIAlertAction(title: "네", style: .destructive) { _ in
      completion()
    }
    
    alert.addAction(no)
    alert.addAction(yes)
    
    self.present(alert, animated: true, completion: nil)
  }
}

// MARK: - NavigationBar Font Configure
extension UIViewController {
  func adjustNavigationBarFont() {
    self.navigationController?.navigationBar.titleTextAttributes = [
      NSAttributedString.Key.font: UIFont(name: "GowunBatang-Bold", size: 17)!
    ]
    
    let BarButtonTextAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "GowunBatang-Bold", size: 16)!
    ]
    
    if let leftBarButtons = self.navigationItem.leftBarButtonItems {
      for button in leftBarButtons {
        button.setTitleTextAttributes(BarButtonTextAttributes, for: .normal)
        button.setTitleTextAttributes(BarButtonTextAttributes, for: .highlighted)
      }
    }
    
    if let rightBarButtons = self.navigationItem.rightBarButtonItems {
      for button in rightBarButtons {
        button.setTitleTextAttributes(BarButtonTextAttributes, for: .normal)
        button.setTitleTextAttributes(BarButtonTextAttributes, for: .highlighted)
      }
    }
  }
}
