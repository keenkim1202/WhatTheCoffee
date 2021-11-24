//
//  AddRecordViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/17.
//

import UIKit

// TODO: ImagePicker 관련 코드. addCoffeeVC와 겹침. 수정해보자.

class AddRecordViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  let imagePicker = UIImagePickerController()
  
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
    imagePicker.delegate = self
    addImageButton.tintColor = UIColor.imageButtonColor
    addImageButton.titleLabel?.textColor = UIColor.oppositeColor
  }
  
  // MARK: - Photo Library & Camera Access
  func openLibrary() {
    imagePicker.sourceType = .photoLibrary
    self.present(imagePicker, animated: false, completion: nil)
  }
  
  func openCamera() {
    if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
      imagePicker.sourceType = .camera
      self.present(imagePicker, animated: false, completion: nil)
    } else {
      showAlert("카메라 사용이 불가합니다.\n권한을 확인해주세요.")
    }
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
    self.dismiss(animated: true, completion: nil)
  }
  
  /// components
  @IBAction func onAddImage(_ sender: UIButton) {
    let alert =  UIAlertController(title: "카페 사진 추가", message: "어디에서 이미지를 불러오시겠습니까?", preferredStyle: .actionSheet)
    let library =  UIAlertAction(title: "사진앨범", style: .default) { (action) in
      self.openLibrary()
    }
    
    let camera =  UIAlertAction(title: "카메라", style: .default) { (action) in
      self.openCamera()
    }
    
    let defaultImage =  UIAlertAction(title: "기본 이미지로 변경", style: .default) { (action) in
      self.recordImageView.image = UIImage(named: "random")
    }
    
    let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
    alert.addAction(library)
    alert.addAction(camera)
    alert.addAction(defaultImage)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
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

// MARK: - Extension - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension AddRecordViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      recordImageView.image = image
    }
    
    dismiss(animated: true, completion: nil)
  }
}
