import UIKit
import TextFieldEffects
import FirebaseAnalytics

class AddRecordViewController: BaseViewController {

  // MARK: - Properties
  var viewModel: AddRecordViewModel!

  let buttonCornerRadius: CGFloat = 20
  let imagePicker = UIImagePickerController()
  let commentPlaceholder: String = "커피/디저트/분위기 등은 어땠나요?"

  // MARK: - UI
  @IBOutlet weak var navigationBar: UINavigationBar!
  @IBOutlet weak var recordImageView: UIImageView!
  @IBOutlet weak var addImageButton: UIButton!

  @IBOutlet weak var titleTextField: IsaoTextField!
  @IBOutlet weak var commentTextView: UITextView!

  @IBOutlet weak var dateTextField: IsaoTextField!
  @IBOutlet weak var verygoodButton: UIButton!
  @IBOutlet weak var goodButton: UIButton!
  @IBOutlet weak var sosoButton: UIButton!
  @IBOutlet weak var badButton: UIButton!
  @IBOutlet weak var verybadButton: UIButton!

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    configureNAV()
    configureButton()
    configureTextView()
    configureTextField()
    configureFromViewModel()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.post(name: NSNotification.Name("DismissAddRecord"), object: nil, userInfo: nil)
  }

  // MARK: - Configure
  func configureFromViewModel() {
    navigationBar.topItem?.title = viewModel.navigationTitle
    recordImageView.image = viewModel.currentImage
    recordImageView.layer.cornerRadius = CGFloat(5)
    titleTextField.text = viewModel.currentName
    dateTextField.text = viewModel.currentDate

    if let rate = viewModel.currentRate {
      updateRate(rate)
    }

    if let comment = viewModel.currentComment, !comment.isEmpty {
      commentTextView.text = comment
      commentTextView.textColor = UIColor.orangeMainColor
    } else {
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
    titleTextField.delegate = self
    dateTextField.setDatePicker(target: self, selector: #selector(datePickerDone))
    dateTextField.textColor = .orangeMainColor
  }

  func configureTextView() {
    commentTextView.delegate = self
    commentTextView.layer.borderWidth = 2
    commentTextView.layer.borderColor = UIColor.greenSubColor.cgColor
    commentTextView.backgroundColor = .appearanceColor
    commentTextView.layer.cornerRadius = CGFloat(8)
    commentTextView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
  }

  func configureNAV() {
    let barTitleTextAttributes: [NSAttributedString.Key: Any] = [
      .font: UIFont(name: "GowunBatang-Bold", size: 17)!
    ]

    let barButtonTextAttributes: [NSAttributedString.Key: Any] = [
      .font: UIFont(name: "GowunBatang-Bold", size: 16)!
    ]

    UINavigationBar.appearance().titleTextAttributes = barTitleTextAttributes

    if let leftBarButtons = self.navigationBar.topItem?.leftBarButtonItems {
      for button in leftBarButtons {
        button.setTitleTextAttributes(barButtonTextAttributes, for: .normal)
        button.setTitleTextAttributes(barButtonTextAttributes, for: .highlighted)
      }
    }

    if let rightBarButtons = self.navigationBar.topItem?.rightBarButtonItems {
      for button in rightBarButtons {
        button.setTitleTextAttributes(barButtonTextAttributes, for: .normal)
        button.setTitleTextAttributes(barButtonTextAttributes, for: .highlighted)
      }
    }
  }

  // MARK: - Photo Library & Camera Access
  func openLibrary() {
    imagePicker.sourceType = .photoLibrary
    self.present(imagePicker, animated: false)
  }

  func openCamera() {
    if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
      imagePicker.sourceType = .camera
      self.present(imagePicker, animated: false)
    } else {
      showErrorAlert("카메라 사용이 불가합니다.\n권한을 확인해주세요.")
    }
  }

  func updateRate(_ rate: Rate) {
    verygoodButton.isSelected = rate == .veryGood
    goodButton.isSelected = rate == .good
    sosoButton.isSelected = rate == .soso
    badButton.isSelected = rate == .bad
    verybadButton.isSelected = rate == .veryBad

    viewModel.rate = rate.rawValue
  }

  @objc func datePickerDone() {
    if let datePicker = self.dateTextField.inputView as? UIDatePicker {
      self.dateTextField.text = DateFormatter.selectDateFormat.string(from: datePicker.date)
    }
    self.dateTextField.resignFirstResponder()
  }

  // MARK: - Actions
  @IBAction func onDone(_ sender: UIBarButtonItem) {
    guard let text = titleTextField.text else { return }
    if text.isEmpty {
      showErrorAlert("카페명을 입력해주세요.")
    } else if viewModel.rate == nil {
      showErrorAlert("별점을 체크해주세요.")
    } else {
      var comment: String? = commentTextView.text
      if comment == commentPlaceholder { comment = nil }

      viewModel.save(name: text, visitDateString: dateTextField.text, comment: comment, image: recordImageView.image)
      Analytics.logEvent("ADD_newRecord", parameters: nil)
      self.dismiss(animated: true)
    }
  }

  @IBAction func onClose(_ sender: UIBarButtonItem) {
    Analytics.logEvent("CANCEL_newRecord", parameters: nil)
    self.dismiss(animated: true)
  }

  @IBAction func onAddImage(_ sender: UIButton) {
    let alert = UIAlertController(title: "카페 사진 추가", message: "어디에서 이미지를 불러오시겠습니까?", preferredStyle: .actionSheet)
    let library = UIAlertAction(title: "사진앨범", style: .default) { _ in self.openLibrary() }
    let camera = UIAlertAction(title: "카메라", style: .default) { _ in self.openCamera() }
    let defaultImage = UIAlertAction(title: "기본 이미지로 변경", style: .default) { _ in
      self.recordImageView.image = UIImage.defaultCafeImage
    }
    let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

    alert.addAction(library)
    alert.addAction(camera)
    alert.addAction(defaultImage)
    alert.addAction(cancel)
    self.present(alert, animated: true)
  }

  @IBAction func onRate(_ sender: UIButton) {
    guard let rate = Rate(rawValue: sender.tag) else { return }
    updateRate(rate)
  }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension AddRecordViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      recordImageView.image = image
    }
    self.dismiss(animated: true)
  }
}

// MARK: - UITextViewDelegate
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

// MARK: - UITextFieldDelegate
extension AddRecordViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == self.titleTextField {
      self.dateTextField.becomeFirstResponder()
    }
    return true
  }
}
