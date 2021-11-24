//
//  AddRecordViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/17.
//

import UIKit

class AddRecordViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  
  // MARK: - UI
  @IBOutlet weak var recordImageView: UIImageView!
  @IBOutlet weak var addImageButton: UIButton!
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var commentTextView: UITextView!
  
  @IBOutlet weak var verygoodButton: UIButton!
  @IBOutlet weak var goodButton: UIButton!
  @IBOutlet weak var sosoButton: UIButton!
  @IBOutlet weak var badButton: UIButton!
  @IBOutlet weak var verybadButton: UIButton!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
  
  // MARK: - Configure
  func configure() {
    self.addImageButton.tintColor = UIColor.imageButtonColor
  }
  
  func updateRate(_ rate: Rate) {
    switch rate {
    case .veryGood:
      verygoodButton.isSelected = true
      goodButton.isSelected = false
      sosoButton.isSelected = false
      badButton.isSelected = false
      verybadButton.isSelected = false
      
    case .good:
      verygoodButton.isSelected = false
      goodButton.isSelected = true
      sosoButton.isSelected = false
      badButton.isSelected = false
      verybadButton.isSelected = false
      
    case .soso:
      verygoodButton.isSelected = false
      goodButton.isSelected = false
      sosoButton.isSelected = true
      badButton.isSelected = false
      verybadButton.isSelected = false
      
    case .bad:
      verygoodButton.isSelected = false
      goodButton.isSelected = false
      sosoButton.isSelected = false
      badButton.isSelected = true
      verybadButton.isSelected = false
      
    case .veryBad:
      verygoodButton.isSelected = false
      goodButton.isSelected = false
      sosoButton.isSelected = false
      badButton.isSelected = false
      verybadButton.isSelected = true
    }
  }
  
  // MARK: - Actions
  /// navigationBarButton
  @IBAction func onDone(_ sender: UIBarButtonItem) {
    print(#function)
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func onClose(_ sender: UIBarButtonItem) {
    print(#function)
    self.dismiss(animated: true, completion: nil)
  }
  
  /// components
  @IBAction func onAddImage(_ sender: UIButton) {
    
  }
  
  @IBAction func onRateButton(_ sender: Any) {
    guard let button = sender as? UIButton else { return }
    guard
      let text = button.titleLabel?.text,
      let rate = Rate(rawValue: button.tag)
    else { return }
    
    let tag = button.tag
    print(text, tag)
    
    updateRate(rate)
    
    
  }
  
  
}
