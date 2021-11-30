//
//  UIViewController++Extension.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/22.
//

import UIKit

// MARK: - Configuring Alert
extension UIViewController {
  func showAlert(_ message: String) {
    UIAlertController
      .show(self, contentType: .error, message: message)
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

extension UIViewController {
  // MARK: - NavigationBar Font Configure
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
