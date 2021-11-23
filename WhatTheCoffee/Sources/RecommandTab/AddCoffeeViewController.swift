//
//  AddCoffeeViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit

class AddCoffeeViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  
  // MARK: - UI
  @IBOutlet weak var coffeeImageView: UIImageView!
  @IBOutlet weak var addImageButton: UIButton!
  @IBOutlet weak var nameTextField: UITextField!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
  
  // MARK: - Configure
  func configure() {
    self.addImageButton.tintColor = UIColor.imageButtonColor
  }
  
  func saveButtonClicked() {
    let task = Coffee(name: nameTextField.text!)
    environment?.coffeeRepository.add(item: task)
    saveImageToDocumentDirectory(imageName: "\(task._id).png", image: coffeeImageView.image!)
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Actions
  /// navigationBarButton
  @IBAction func onDone(_ sender: UIBarButtonItem) {
    print(#function)
    
    // TODO: 이미지 저장에 실패한 경우 처리하기
    // text가 비어있으면 alert문을 띄우고 저장하지 않음.
    if let text = nameTextField.text {
      if text.isEmpty {
        
      } else {
        // text가 있으면 저장.
        saveButtonClicked()
        self.navigationController?.popViewController(animated: true)
      }
    }
  }
  
  /// components
  @IBAction func onAddImage(_ sender: UIButton) {
  }
  
}
