import UIKit
import FirebaseAnalytics
import TextFieldEffects

class AddCoffeeViewController: BaseViewController {

  // MARK: - Properties
  var viewModel: AddCoffeeViewModel!

  let imagePicker: UIImagePickerController = {
    let imagePicker = UIImagePickerController()
    imagePicker.allowsEditing = true
    return imagePicker
  }()
  let buttonCornerRadius: CGFloat = 20

  // MARK: - UI
  @IBOutlet weak var coffeeImageView: UIImageView!
  @IBOutlet weak var addImageButton: UIButton!
  @IBOutlet weak var nameTextField: IsaoTextField!

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    configureNAV()
    configure()
  }

  // MARK: - Configure
  func configure() {
    imagePicker.delegate = self
    nameTextField.delegate = self

    coffeeImageView.layer.cornerRadius = CGFloat(5)
    addImageButton.layer.cornerRadius = buttonCornerRadius
    addImageButton.tintColor = UIColor.greenSubColor
    addImageButton.titleLabel?.textColor = UIColor.oppositeColor
  }

  func configureNAV() {
    let cancelBarButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(onCancel))
    let saveBarButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(onSave))

    navigationItem.leftBarButtonItem = cancelBarButton
    navigationItem.rightBarButtonItem = saveBarButton

    title = viewModel.title
    nameTextField.text = viewModel.currentName
    coffeeImageView.image = viewModel.currentImage
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

  // MARK: - Actions
  @objc func onCancel() {
    Analytics.logEvent("CANCEL_newCoffee", parameters: nil)
    self.navigationController?.popViewController(animated: true)
  }

  @objc func onSave() {
    guard let text = nameTextField.text else { return }

    if text.isEmpty {
      showErrorAlert("커피명을 입력해주세요.")
    } else {
      viewModel.save(name: text, image: coffeeImageView.image)
      Analytics.logEvent("ADD_newCoffee", parameters: ["커피명": text])
      self.navigationController?.popViewController(animated: true)
    }
  }

  @IBAction func onAddImage(_ sender: UIButton) {
    let alert = UIAlertController(title: "카페 사진 추가", message: "어디에서 이미지를 불러오시겠습니까?", preferredStyle: .actionSheet)
    let library = UIAlertAction(title: "사진앨범", style: .default) { _ in self.openLibrary() }
    let camera = UIAlertAction(title: "카메라", style: .default) { _ in self.openCamera() }
    let defaultImage = UIAlertAction(title: "기본 이미지로 변경", style: .default) { _ in
      self.coffeeImageView.image = UIImage.randomCoffeeImage
    }
    let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

    alert.addAction(library)
    alert.addAction(camera)
    alert.addAction(defaultImage)
    alert.addAction(cancel)
    self.present(alert, animated: true)
  }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension AddCoffeeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      coffeeImageView.image = image
    }
    self.dismiss(animated: true)
  }
}

// MARK: - UITextFieldDelegate
extension AddCoffeeViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    nameTextField.resignFirstResponder()
    return true
  }
}
