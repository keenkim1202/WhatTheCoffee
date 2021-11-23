//
//  AddCoffeeViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit

// TODO: 화면 전환 시, 버튼 색상이 원하는대로 안뜸. 버튼을 눌러야지 색상이 바뀜.

class AddCoffeeViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  var coffee: Coffee?
  let imagePicker = UIImagePickerController()
  
  // MARK: - UI
  @IBOutlet weak var coffeeImageView: UIImageView!
  @IBOutlet weak var addImageButton: UIButton!
  @IBOutlet weak var nameTextField: UITextField!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    print(#function)
    configure()
  }
  
  // MARK: - Configure
  func configure() {
    imagePicker.delegate = self
    addImageButton.tintColor = UIColor.imageButtonColor
    addImageButton.titleLabel?.textColor = UIColor.oppositeColor

    // TODO: 이미지가 없거나 불러오기에 실패한 경우 처리하기
    if let coffee = coffee {
      nameTextField.text = coffee.name
      coffeeImageView.image = loadImageFromDocumentDirectory(imageName: "\(coffee._id).jpg")
    }

  }
  
  func saveButtonClicked() {
    let item = Coffee(name: nameTextField.text!)
    environment?.coffeeRepository.add(item: item)
    
    if coffeeImageView.image != UIImage(named: "random") {
      saveImageToDocumentDirectory(imageName: "\(item._id).jpg", image: coffeeImageView.image!)
    }
    self.navigationController?.popViewController(animated: true)
  }
  
  // MARK: Photo Library & Camera Access
  func openLibrary() {
    imagePicker.sourceType = .photoLibrary
    present(imagePicker, animated: false, completion: nil)
  }
  
  func openCamera() {
    if(UIImagePickerController .isSourceTypeAvailable(.camera)) {
      imagePicker.sourceType = .camera
      present(imagePicker, animated: false, completion: nil)
    }
    else{
      print("Camera not available")
    }
  }
  
  // MARK: - Actions
  /// navigationBarButton
  @IBAction func onDone(_ sender: UIBarButtonItem) {
    print(#function)
    
    // TODO: 이미지 저장에 실패한 경우 처리하기
    if let text = nameTextField.text {
      if text.isEmpty {
        showAlert("카페명을 입력해주세요.")
      } else {
        saveButtonClicked()
        self.navigationController?.popViewController(animated: true)
      }
    }
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
      self.coffeeImageView.image = UIImage(systemName: "folder")
    }
    
    let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
    alert.addAction(library)
    alert.addAction(camera)
    alert.addAction(defaultImage)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
  }
  
}

// MARK: - Extension - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension AddCoffeeViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      coffeeImageView.image = image
      print(info)
    }
    
    dismiss(animated: true, completion: nil)
  }
}
