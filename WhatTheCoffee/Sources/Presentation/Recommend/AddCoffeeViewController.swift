import UIKit
import FirebaseAnalytics
import TextFieldEffects

class AddCoffeeViewController: BaseViewController {

  // MARK: - Properties
  let viewModel: AddCoffeeViewModel
  let imagePicker: UIImagePickerController = {
    let picker = UIImagePickerController()
    picker.allowsEditing = true
    return picker
  }()
  let buttonCornerRadius: CGFloat = 20

  // MARK: - UI
  private let coffeeImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    iv.layer.cornerRadius = 5
    iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()

  private lazy var addImageButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("커피 이미지 추가하기", for: .normal)
    button.setTitleColor(UIColor(named: "GreenMainColor"), for: .normal)
    button.titleLabel?.font = UIFont(name: "GowunBatang-Bold", size: 15)
    button.backgroundColor = UIColor(named: "GreenSubColor")
    button.layer.cornerRadius = buttonCornerRadius
    button.addTarget(self, action: #selector(onAddImage), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let coffeeTitleLabel: UILabel = {
    let label = UILabel()
    label.text = "커피 명"
    label.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let nameTextField: IsaoTextField = {
    let tf = IsaoTextField()
    tf.placeholder = "어떤 커피 인가요?"
    tf.font = UIFont.GowunBatang(type: .regular, size: 15)
    tf.textColor = UIColor(named: "OrangeMainColor")
    tf.inactiveColor = UIColor(named: "GreenSubColor")
    tf.activeColor = UIColor(named: "OrangeMainColor")
    tf.autocorrectionType = .no
    tf.spellCheckingType = .no
    tf.returnKeyType = .done
    tf.smartDashesType = .no
    tf.smartInsertDeleteType = .no
    tf.smartQuotesType = .no
    tf.translatesAutoresizingMaskIntoConstraints = false
    return tf
  }()

  // MARK: - Init
  init(viewModel: AddCoffeeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNav()
    configureLayout()
    configure()
  }

  // MARK: - Configure
  private func configure() {
    imagePicker.delegate = self
    nameTextField.delegate = self

    title = viewModel.title
    nameTextField.text = viewModel.currentName
    coffeeImageView.image = viewModel.currentImage
  }

  private func configureNav() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(onCancel))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(onSave))
  }

  private func configureLayout() {
    view.backgroundColor = .systemBackground

    let imageStack = UIStackView(arrangedSubviews: [coffeeImageView, addImageButton])
    imageStack.axis = .vertical
    imageStack.alignment = .center
    imageStack.spacing = 20
    imageStack.translatesAutoresizingMaskIntoConstraints = false

    let textStack = UIStackView(arrangedSubviews: [coffeeTitleLabel, nameTextField])
    textStack.axis = .vertical
    textStack.alignment = .center
    textStack.spacing = 20
    textStack.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(imageStack)
    view.addSubview(textStack)

    NSLayoutConstraint.activate([
      imageStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
      imageStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
      imageStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),

      coffeeImageView.widthAnchor.constraint(equalTo: coffeeImageView.heightAnchor),
      coffeeImageView.leadingAnchor.constraint(equalTo: imageStack.leadingAnchor, constant: 37),
      coffeeImageView.trailingAnchor.constraint(equalTo: imageStack.trailingAnchor, constant: -37),

      addImageButton.leadingAnchor.constraint(equalTo: imageStack.leadingAnchor),
      addImageButton.trailingAnchor.constraint(equalTo: imageStack.trailingAnchor),
      addImageButton.widthAnchor.constraint(equalTo: addImageButton.heightAnchor, multiplier: 7),

      textStack.topAnchor.constraint(equalTo: imageStack.bottomAnchor, constant: 50),
      textStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      textStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

      coffeeTitleLabel.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
      coffeeTitleLabel.trailingAnchor.constraint(equalTo: textStack.trailingAnchor),

      nameTextField.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
      nameTextField.trailingAnchor.constraint(equalTo: textStack.trailingAnchor),
      nameTextField.heightAnchor.constraint(equalToConstant: 50)
    ])
  }

  // MARK: - Photo Library & Camera Access
  private func openLibrary() {
    imagePicker.sourceType = .photoLibrary
    present(imagePicker, animated: false)
  }

  private func openCamera() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      imagePicker.sourceType = .camera
      present(imagePicker, animated: false)
    } else {
      showErrorAlert("카메라 사용이 불가합니다.\n권한을 확인해주세요.")
    }
  }

  // MARK: - Actions
  @objc private func onCancel() {
    Analytics.logEvent("CANCEL_newCoffee", parameters: nil)
    navigationController?.popViewController(animated: true)
  }

  @objc private func onSave() {
    guard let text = nameTextField.text else { return }

    if text.isEmpty {
      showErrorAlert("커피명을 입력해주세요.")
    } else {
      viewModel.save(name: text, image: coffeeImageView.image)
      Analytics.logEvent("ADD_newCoffee", parameters: ["커피명": text])
      navigationController?.popViewController(animated: true)
    }
  }

  @objc private func onAddImage() {
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
    present(alert, animated: true)
  }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension AddCoffeeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      coffeeImageView.image = image
    }
    dismiss(animated: true)
  }
}

// MARK: - UITextFieldDelegate
extension AddCoffeeViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    nameTextField.resignFirstResponder()
    return true
  }
}
