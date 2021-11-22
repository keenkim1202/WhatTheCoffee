//
//  AddCoffeeViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit

class AddCoffeeViewController: UIViewController {
  
  // MARK: - UI
  @IBOutlet weak var addImageButton: UIButton!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
  
  // MARK: - Configure
  func configure() {
    self.addImageButton.tintColor = UIColor.imageButtonColor
  }
  
  // MARK: - Actions
  /// navigationBarButton
  @IBAction func onDone(_ sender: UIBarButtonItem) {
    print(#function)
    self.navigationController?.popViewController(animated: true)
  }
  
  /// components
  @IBAction func onAddImage(_ sender: UIButton) {
  }
  
}
