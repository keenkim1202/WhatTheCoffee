//
//  AddCoffeeViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit

// TODO: 카메라 및 사진첩 접근 권한 묻도록 설정하기.
// TODO: 화면 전환 시, 버튼 색상이 원하는대로 안뜸. 버튼을 눌러야지 색상이 바뀜.

class AddCoffeeViewController: UIViewController {
  
  // MARK: - Enum
  enum ViewType {
    case add
    case update
  }
  
  // MARK: - Properties
  let imagePicker = UIImagePickerController()
  let buttonCornerRadius: CGFloat = 25
  
  var environment: Environment? = nil
  var viewType: ViewType = .add
  var coffee: Coffee?

  
  // MARK: - UI
  @IBOutlet weak var coffeeImageView: UIImageView!
  @IBOutlet weak var addImageButton: UIButton!
  @IBOutlet weak var nameTextField: UITextField!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureNAV()
    configure()
  }
  
  // MARK: - Configure
  func configure() {
    imagePicker.delegate = self
    addImageButton.layer.cornerRadius = buttonCornerRadius
    addImageButton.tintColor = UIColor.imageButtonColor
    addImageButton.titleLabel?.textColor = UIColor.oppositeColor
  }
  
  func configureNAV() {
    let cancelBarButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(onCancel))
    let saveBarButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(onSave))
    
    navigationItem.leftBarButtonItem = cancelBarButton
    navigationItem.rightBarButtonItem = saveBarButton
    
    // TODO: 이미지가 없거나 불러오기에 실패한 경우 처리하기
    if let coffee = coffee {
      viewType = .update
      title = "커피 수정"
      nameTextField.text = coffee.name
      coffeeImageView.image = loadImageFromDocumentDirectory(imageName: "\(coffee._id).jpg") ?? UIImage(named: "random")
    } else {
      title = "커피 추가"
      coffeeImageView.image = UIImage(named: "random")
    }

  }
  
  func saveData() {
    // 만약 기본이미지이면 이미지는 저장하지 않음.
    guard let env = environment else {
      print("addCoffeeVC - env nil..")
      return
    }
    guard let coffeeName = nameTextField.text else { return }
    
    let item = Coffee(name: coffeeName)
    print(item)
    
    if viewType == .update {
      guard let coffee = coffee else { return }
      env.coffeeRepository.update(item: coffee, new: item)
    } else {
      env.coffeeRepository.add(item: item)
    }
    
    if coffeeImageView.image != UIImage(named: "random") {
      saveImageToDocumentDirectory(imageName: "\(item._id).jpg", image: coffeeImageView.image!)
    }
    
    self.navigationController?.popViewController(animated: true)
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
  
  // MARK: - Actions
  /// navigationBarButton
  @objc func onCancel() {
    self.navigationController?.popViewController(animated: true)
  }
  
  @objc func onSave() {
    // TODO: 이미지 저장에 실패한 경우 처리하기
    guard let text = nameTextField.text else { return }
    
    if text.isEmpty {
      showAlert("카페명을 입력해주세요.")
    } else {
      saveData()
      self.navigationController?.popViewController(animated: true)
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
      self.coffeeImageView.image = UIImage(named: "random")
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
    }
    
    dismiss(animated: true, completion: nil)
  }
}
