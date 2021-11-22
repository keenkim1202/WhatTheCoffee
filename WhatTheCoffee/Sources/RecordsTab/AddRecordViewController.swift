//
//  AddRecordViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/17.
//

import UIKit

class AddRecordViewController: UIViewController {
  
  // MARK: - UI
  @IBOutlet weak var recordImageView: UIImageView!
  @IBOutlet weak var addImageButton: UIButton!
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var commandTextView: UITextView!
  
  
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
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func onClose(_ sender: UIBarButtonItem) {
    print(#function)
    self.dismiss(animated: true, completion: nil)
  }
  
  /// components
  @IBAction func onAddImage(_ sender: UIButton) {
  }
  
  
  
}
