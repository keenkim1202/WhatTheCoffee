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
  
  // MARK: - Document Date Manage
  func saveImageToDocumentDirectory(imageName: String, image: UIImage) {
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    let imageURL = documentDirectory.appendingPathComponent(imageName)
  
    guard let data = image.pngData() else { return }
    
    if FileManager.default.fileExists(atPath: imageURL.path) {
      do {
        try FileManager.default.removeItem(at: imageURL)
        print("SUCCESS - image deleted.")
      } catch {
        print("FAILED - fail to delete image.")
      }
    }
  
    do {
      try data.write(to: imageURL)
      print("SUCCESS - image saved.")
    } catch {
      print("FAILED - fail to save image.")
    }
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
