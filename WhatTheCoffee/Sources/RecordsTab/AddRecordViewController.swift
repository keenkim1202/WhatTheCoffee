//
//  AddRecordViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/17.
//

import UIKit

// TODO: ImagePicker 관련 코드. addCoffeeVC와 겹침. 수정해보자.

class AddRecordViewController: UIViewController {
  
  // MARK: - ViewType
  enum ViewType {
    case add
    case update
  }
  
  // MARK: - Properties
  let buttonCornerRadius: CGFloat = 25
  let imagePicker = UIImagePickerController()
  let commentPlaceholder: String = "커피/디저트/분위기 등은 어땠나요?"
  
  var environment: Environment? = nil
  var viewType: ViewType = .add
  var cafe: Cafe?
  var rate: Int?
  
  // MARK: - UI
  @IBOutlet weak var recordImageView: UIImageView!
  @IBOutlet weak var addImageButton: UIButton!
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var commentTextView: UITextView!
  
  
  @IBOutlet weak var dateTextField: UITextField!
  @IBOutlet weak var verygoodButton: UIButton!
  @IBOutlet weak var goodButton: UIButton!
  @IBOutlet weak var sosoButton: UIButton!
  @IBOutlet weak var badButton: UIButton!
  @IBOutlet weak var verybadButton: UIButton!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureButton()
    configureTextView()
    configureTextField()
    configure()
  }
  
  // MARK: - Configure
  func configure() {
    // TODO: 좀 더 깔끔하게 정리할 수 있을 것 같음. 나중에 수정하기
    if let cafe = cafe {
      viewType = .update
      title = "기록 수정"
      
      let date = DateFormatter.selectDateFormat.string(from: cafe.visitDate)
      recordImageView.image = loadImageFromDocumentDirectory(imageName: "\(cafe._id).jpg") ?? UIImage(named: "cafeDefault3")
      titleTextField.text = cafe.name
      dateTextField.text = date
      updateRate(Rate.init(rawValue: cafe.rate)!)

      if let comment = cafe.comment, !comment.isEmpty {
        commentTextView.text = comment
        commentTextView.textColor = UIColor.orangeMainColor
      } else {
        commentTextView.text = commentPlaceholder
        commentTextView.textColor = UIColor.placeholderText
      }

    } else {
      title = "기록 추가"
      recordImageView.image = UIImage(named: "cafeDefault3")
      commentTextView.text = commentPlaceholder
      commentTextView.textColor = UIColor.placeholderText
    }
  }
  
  func configureButton() {
    imagePicker.delegate = self

    addImageButton.layer.cornerRadius = buttonCornerRadius
    addImageButton.tintColor = UIColor.greenSubColor
    addImageButton.titleLabel?.textColor = UIColor.oppositeColor
  }
  
  func configureTextField() {
    dateTextField.setDatePicker(target: self, selector: #selector(datePickerDone))
    dateTextField.textColor = .orangeMainColor
    dateTextField.textAlignment = .center
  }
  
  func configureTextView() {
    commentTextView.delegate = self
    commentTextView.layer.borderWidth = 0.5
    commentTextView.layer.borderColor = UIColor.placeholderText.cgColor
    commentTextView.backgroundColor = .appearanceColor
    commentTextView.layer.cornerRadius = CGFloat(8)
    commentTextView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
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
  
  func updateRate(_ rate: Rate) { // 별점 버튼을 눌렀을 때 한 가지만 선택되도록 하기 위한 함수 입니다.
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
    
    self.rate = rate.rawValue
  }
  
  func saveData() {
    // 만약 기본이미지이면 이미지는 저장하지 않음.
    guard let env = environment else { return }
    guard let cafeName = titleTextField.text else { return }
    guard let visitDate = dateTextField.text else { return }
    guard let rate = rate else { return }
    guard let commentText = commentTextView.text else { return }
    
    var comment: String? = ""
    
    if commentText == commentPlaceholder {
      comment = nil
    } else {
      comment = commentText
    }
    
    var item = Cafe(name: cafeName, comment: comment, rate: rate)
    
    if let date = DateFormatter.selectDateFormat.date(from: visitDate) {
      item = Cafe(name: cafeName, visitDate: date, comment: comment, rate: rate)
    }
    
    print(item)

    if viewType == .update {
      guard let cafe = cafe else { return }
      env.cafeRepository.update(item: cafe, new: item)
    } else {
      env.cafeRepository.add(item: item)
    }

    if recordImageView.image != UIImage(named: "cafeDefault3") {
      saveImageToDocumentDirectory(imageName: "\(item._id).jpg", image: recordImageView.image!)
    }

    self.navigationController?.popViewController(animated: true)
  }
  
  @objc func datePickerDone() {
    if let datePicker = self.dateTextField.inputView as? UIDatePicker {
      self.dateTextField.text = DateFormatter.selectDateFormat.string(from: datePicker.date)
    }
    self.dateTextField.resignFirstResponder()
  }
  
  // MARK: - Actions
  /// navigationBarButton
  @IBAction func onDone(_ sender: UIBarButtonItem) {
    guard let text = titleTextField.text else { return }
    if text.isEmpty {
      showAlert("카페명을 입력해주세요.")
    } else if rate == nil {
      showAlert("별점을 체크해주세요.")
    } else {
      saveData()
      self.dismiss(animated: true, completion: nil)
    }
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
      self.recordImageView.image = UIImage(named: "cafeDefault3")
    }
    
    let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    
    alert.addAction(library)
    alert.addAction(camera)
    alert.addAction(defaultImage)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
  }
  
  @IBAction func onRate(_ sender: UIButton) {
    guard let rate = Rate(rawValue: sender.tag) else { return }
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

// MARK: - Extension - UITextViewDelegate
extension AddRecordViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if commentTextView.textColor == UIColor.placeholderText {
      if commentTextView.text == commentPlaceholder {
        commentTextView.text = nil
      }
      commentTextView.textColor = UIColor.orangeMainColor
    }
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    if commentTextView.text.isEmpty {
      commentTextView.text = commentPlaceholder
      commentTextView.textColor = UIColor.placeholderText
    }
  }
}
