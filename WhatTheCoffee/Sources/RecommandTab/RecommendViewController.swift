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
  @IBOutlet weak var recommendButton: UIButton!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }

  // MARK: - Configure
  func configure() {
    recommendButton.tintColor = UIColor.recommendButtonColor
    recommendButton.titleLabel?.textColor = UIColor.oppositeColor
  }
  
  // MARK: - Actions

  @IBAction func onRecommend(_ sender: UIButton) {
    
  }
  
}
