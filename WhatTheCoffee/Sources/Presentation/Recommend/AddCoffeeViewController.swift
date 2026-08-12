import UIKit
import PhotosUI
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
  private let cutoutIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .large)
    indicator.hidesWhenStopped = true
    indicator.translatesAutoresizingMaskIntoConstraints = false
    return indicator
  }()

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

    view.addSubview(cutoutIndicator)

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

      cutoutIndicator.centerXAnchor.constraint(equalTo: coffeeImageView.centerXAnchor),
      cutoutIndicator.centerYAnchor.constraint(equalTo: coffeeImageView.centerYAnchor),

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
  /// 사진 라이브러리는 PHPicker를 쓴다. 앱 밖에서 뜨기 때문에 UIImagePickerController보다 빠르고
  /// 사진 접근 권한도 필요 없다. 카메라는 PHPicker가 다루지 못해 기존 방식을 유지한다.
  private func openLibrary() {
    var configuration = PHPickerConfiguration()
    configuration.filter = .images
    configuration.selectionLimit = 1

    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = self
    present(picker, animated: true)
  }

  private func openCamera() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      imagePicker.sourceType = .camera
      present(imagePicker, animated: true)
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
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      dismiss(animated: true)
      return
    }

    dismiss(animated: true) { [weak self] in
      self?.applyCutout(to: image)
    }
  }

  /// 배경을 지우고 피사체만 남긴다. 피사체를 못 찾은 사진은 쓰지 않는다.
  private func applyCutout(to image: UIImage) {
    // 분석이 끝나기 전에 저장하면 이전 이미지가 저장되고 결과는 버려진다.
    setAnalyzing(true)

    SubjectCutout.extractSubjects(from: image) { [weak self] result in
      guard let self else { return }
      setAnalyzing(false)

      switch result {
      case .success(let subjects):
        // 잘라낸 것 말고 원본을 쓰고 싶을 수 있으니 마지막 선택지로 함께 보여준다.
        presentSubjectPicker(subjects + [SubjectCutout.Subject(title: "원본", image: image)])
      case .failure(let error):
        // 떼어낼 피사체가 없으면 원본을 그대로 쓴다.
        // 배경이 남는 이유를 모르면 기능이 고장난 것처럼 보이므로 짧게 알린다.
        coffeeImageView.image = image

        if case SubjectCutout.Failure.subjectNotFound = error {
          showErrorAlert("사진에서 피사체를 찾지 못해\n원본을 그대로 사용합니다.")
        } else {
          showErrorAlert("이 기기에서는 사진 분석을 사용할 수 없어\n원본을 그대로 사용합니다.")
        }
      }
    }
  }

  private func setAnalyzing(_ isAnalyzing: Bool) {
    if isAnalyzing {
      cutoutIndicator.startAnimating()
    } else {
      cutoutIndicator.stopAnimating()
    }
    navigationItem.rightBarButtonItem?.isEnabled = !isAnalyzing
    addImageButton.isEnabled = !isAnalyzing
  }

  private func presentSubjectPicker(_ subjects: [SubjectCutout.Subject]) {
    let picker = SubjectPickerViewController(subjects: subjects) { [weak self] image in
      self?.coffeeImageView.image = image
    }

    if let sheet = picker.sheetPresentationController {
      sheet.detents = [.medium(), .large()]
      sheet.prefersGrabberVisible = true
    }
    present(picker, animated: true)
  }
}

// MARK: - UITextFieldDelegate
extension AddCoffeeViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    nameTextField.resignFirstResponder()
    return true
  }
}

// MARK: - PHPickerViewControllerDelegate
extension AddCoffeeViewController: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    picker.dismiss(animated: true)

    let provider = results.first?.itemProvider
    guard let provider, provider.canLoadObject(ofClass: UIImage.self) else { return }

    // iCloud에 있는 사진은 내려받느라 시간이 걸린다. 그 사이 저장하면 이전 이미지가 저장된다.
    setAnalyzing(true)

    provider.loadObject(ofClass: UIImage.self) { object, _ in
      DispatchQueue.main.async { [weak self] in
        guard let self else { return }
        guard let image = object as? UIImage else {
          setAnalyzing(false)
          showErrorAlert("사진을 불러오지 못했습니다.")
          return
        }
        applyCutout(to: image)
      }
    }
  }
}
