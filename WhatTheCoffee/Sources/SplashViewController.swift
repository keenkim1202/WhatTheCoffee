//
//  SplashViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/26.
//

import UIKit

class SplashViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment!
  fileprivate var appDelegate: AppDelegate!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    print("splash")
    guard
      let tabbar = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController,
      let nc = storyboard?
        .instantiateViewController(withIdentifier: "recommnadNAV")
        as? UINavigationController,
      let vc = nc.viewControllers.first as? RecommendViewController
    else { return }
    
    self.present(tabbar, animated: true, completion: nil)
//    appDelegate = UIApplication.shared.delegate as? AppDelegate
  }
}
