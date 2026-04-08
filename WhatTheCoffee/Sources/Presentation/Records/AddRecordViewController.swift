import UIKit
import TextFieldEffects
import FirebaseAnalytics

class AddRecordViewController: BaseViewController {

  // MARK: - Properties
  let viewModel: AddRecordViewModel
  let buttonCornerRadius: CGFloat = 20
  let imagePicker = UIImagePickerController()
  let commentPlaceholder: String = "커피/디저트/분위기 등은 어땠나요?"

  // MARK: - UI
  private let navigationBar: UINavigationBar = {
    let bar = UINavigationBar()
    bar.barTintColor = UIColor(named: "AppearanceColor")
    bar.translatesAutoresizingMaskIntoConstraints = false
    return bar
  }()

  private let navBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(named: "NaviColor")
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private let recordImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    iv.layer.cornerRadius = 5
    iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()

  private lazy var addImageButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("카페 이미지 추가하기", for: .normal)
    button.setTitleColor(UIColor(named: "GreenMainColor"), for: .normal)
    button.titleLabel?.font = UIFont(name: "GowunBatang-Bold", size: 15)
    button.backgroundColor = UIColor(named: "GreenSubColor")
    button.layer.cornerRadius = buttonCornerRadius
    button.addTarget(self, action: #selector(onAddImage), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let titleTextField: IsaoTextField = {
    let tf = IsaoTextField()
    tf.placeholder = "카페 이름이 무엇인가요?"
    tf.font = UIFont.GowunBatang(type: .regular, size: 15)
    tf.textColor = UIColor(named: "OrangeMainColor")
    tf.backgroundColor = UIColor(named: "AppearanceColor")
    tf.inactiveColor = UIColor(named: "GreenSubColor")
    tf.activeColor = UIColor(named: "OrangeMainColor")
    tf.autocorrectionType = .no
    tf.spellCheckingType = .no
    tf.returnKeyType = .next
    tf.smartDashesType = .no
    tf.smartInsertDeleteType = .no
    tf.smartQuotesType = .no
    tf.translatesAutoresizingMaskIntoConstraints = false
    return tf
  }()

  private let dateTextField: IsaoTextField = {
    let tf = IsaoTextField()
    tf.placeholder = "언제 방문하셨나요?"
    tf.font = UIFont.GowunBatang(type: .regular, size: 15)
    tf.textColor = UIColor(named: "OrangeMainColor")
    tf.inactiveColor = UIColor(named: "GreenSubColor")
    tf.activeColor = UIColor(named: "OrangeMainColor")
    tf.autocorrectionType = .no
    tf.spellCheckingType = .no
    tf.returnKeyType = .next
    tf.smartDashesType = .no
    tf.smartInsertDeleteType = .no
    tf.smartQuotesType = .no
    tf.translatesAutoresizingMaskIntoConstraints = false
    return tf
  }()

  private let commentTextView: UITextView = {
    let tv = UITextView()
    tv.font = UIFont.GowunBatang(type: .regular, size: 13)
    tv.textColor = .placeholderText
    tv.backgroundColor = UIColor(named: "AppearanceColor")
    tv.layer.borderWidth = 2
    tv.layer.borderColor = UIColor.greenSubColor.cgColor
    tv.layer.cornerRadius = 8
    tv.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    tv.keyboardDismissMode = .onDrag
    tv.autocorrectionType = .no
    tv.spellCheckingType = .no
    tv.smartDashesType = .no
    tv.smartInsertDeleteType = .no
    tv.smartQuotesType = .no
    tv.translatesAutoresizingMaskIntoConstraints = false
    return tv
  }()

  private var rateButtons: [UIButton] = []

  private let scrollView: UIScrollView = {
    let sv = UIScrollView()
    sv.keyboardDismissMode = .onDrag
    sv.translatesAutoresizingMaskIntoConstraints = false
    return sv
  }()

  private let contentView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  // MARK: - Init
  init(viewModel: AddRecordViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .fullScreen
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNav()
    configureLayout()
    configureFromViewModel()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.post(name: NSNotification.Name("DismissAddRecord"), object: nil, userInfo: nil)
  }

  // MARK: - Configure
  private func configureFromViewModel() {
    recordImageView.image = viewModel.currentImage
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

  private func configureNav() {
    let navItem = UINavigationItem(title: viewModel.navigationTitle)
    navItem.leftBarButtonItem = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(onClose))
    navItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(onDone))
    navigationBar.items = [navItem]

    let barTitleTextAttributes: [NSAttributedString.Key: Any] = [
      .font: UIFont(name: "GowunBatang-Bold", size: 17)!
    ]
    let barButtonTextAttributes: [NSAttributedString.Key: Any] = [
      .font: UIFont(name: "GowunBatang-Bold", size: 16)!
    ]
    UINavigationBar.appearance().titleTextAttributes = barTitleTextAttributes
    navItem.leftBarButtonItem?.setTitleTextAttributes(barButtonTextAttributes, for: .normal)
    navItem.leftBarButtonItem?.setTitleTextAttributes(barButtonTextAttributes, for: .highlighted)
    navItem.rightBarButtonItem?.setTitleTextAttributes(barButtonTextAttributes, for: .normal)
    navItem.rightBarButtonItem?.setTitleTextAttributes(barButtonTextAttributes, for: .highlighted)
  }

  private func configureLayout() {
    view.backgroundColor = .systemBackground

    imagePicker.delegate = self
    titleTextField.delegate = self
    commentTextView.delegate = self
    dateTextField.setDatePicker(target: self, selector: #selector(datePickerDone))

    view.addSubview(navBackgroundView)
    view.addSubview(navigationBar)
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)

    // 이미지 섹션
    let imageStack = UIStackView(arrangedSubviews: [recordImageView, addImageButton])
    imageStack.axis = .vertical
    imageStack.alignment = .center
    imageStack.spacing = 15
    imageStack.translatesAutoresizingMaskIntoConstraints = false

    // 카페명 섹션
    let titleLabel = makeSectionLabel("카페 명")
    let titleStack = UIStackView(arrangedSubviews: [titleLabel, titleTextField])
    titleStack.axis = .vertical
    titleStack.alignment = .center
    titleStack.distribution = .fillProportionally
    titleStack.spacing = 15
    titleStack.translatesAutoresizingMaskIntoConstraints = false

    // 방문일 섹션
    let dateLabel = makeSectionLabel("방문일")
    let dateStack = UIStackView(arrangedSubviews: [dateLabel, dateTextField])
    dateStack.axis = .vertical
    dateStack.alignment = .center
    dateStack.distribution = .fillProportionally
    dateStack.spacing = 15
    dateStack.translatesAutoresizingMaskIntoConstraints = false

    // 평점 섹션
    let rateLabel = makeSectionLabel("평점")
    let rateRow = makeRateRow()
    let rateStack = UIStackView(arrangedSubviews: [rateLabel, rateRow])
    rateStack.axis = .vertical
    rateStack.alignment = .center
    rateStack.spacing = 10
    rateStack.translatesAutoresizingMaskIntoConstraints = false

    // 코멘트 섹션
    let commentLabel = makeSectionLabel("코멘트")
    let commentStack = UIStackView(arrangedSubviews: [commentLabel, commentTextView])
    commentStack.axis = .vertical
    commentStack.alignment = .center
    commentStack.spacing = 15
    commentStack.translatesAutoresizingMaskIntoConstraints = false

    // 전체 스택
    let mainStack = UIStackView(arrangedSubviews: [imageStack, titleStack, dateStack, rateStack, commentStack])
    mainStack.axis = .vertical
    mainStack.alignment = .center
    mainStack.spacing = 40
    mainStack.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(mainStack)

    NSLayoutConstraint.activate([
      navBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
      navBackgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      navBackgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      navBackgroundView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),

      navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      navigationBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      navigationBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

      scrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

      contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

      mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
      mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

      // 이미지 섹션
      imageStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 10),
      imageStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -10),
      recordImageView.leadingAnchor.constraint(equalTo: imageStack.leadingAnchor, constant: 20),
      recordImageView.trailingAnchor.constraint(equalTo: imageStack.trailingAnchor, constant: -20),
      recordImageView.widthAnchor.constraint(equalTo: recordImageView.heightAnchor),
      addImageButton.leadingAnchor.constraint(equalTo: imageStack.leadingAnchor),
      addImageButton.trailingAnchor.constraint(equalTo: imageStack.trailingAnchor),
      addImageButton.widthAnchor.constraint(equalTo: addImageButton.heightAnchor, multiplier: 7),

      // 카페명 섹션
      titleStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 10),
      titleStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -10),
      titleLabel.leadingAnchor.constraint(equalTo: titleStack.leadingAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: titleStack.trailingAnchor),
      titleTextField.leadingAnchor.constraint(equalTo: titleStack.leadingAnchor),
      titleTextField.trailingAnchor.constraint(equalTo: titleStack.trailingAnchor),
      titleTextField.heightAnchor.constraint(equalToConstant: 50),

      // 방문일 섹션
      dateStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 10),
      dateStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -10),
      dateLabel.leadingAnchor.constraint(equalTo: dateStack.leadingAnchor),
      dateLabel.trailingAnchor.constraint(equalTo: dateStack.trailingAnchor),
      dateTextField.leadingAnchor.constraint(equalTo: dateStack.leadingAnchor),
      dateTextField.trailingAnchor.constraint(equalTo: dateStack.trailingAnchor),
      dateTextField.heightAnchor.constraint(equalToConstant: 50),

      // 평점 섹션
      rateStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
      rateStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
      rateLabel.leadingAnchor.constraint(equalTo: rateStack.leadingAnchor),
      rateLabel.trailingAnchor.constraint(equalTo: rateStack.trailingAnchor),
      rateRow.leadingAnchor.constraint(equalTo: rateStack.leadingAnchor),
      rateRow.trailingAnchor.constraint(equalTo: rateStack.trailingAnchor),

      // 코멘트 섹션
      commentStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 10),
      commentStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -10),
      commentLabel.leadingAnchor.constraint(equalTo: commentStack.leadingAnchor),
      commentLabel.trailingAnchor.constraint(equalTo: commentStack.trailingAnchor),
      commentTextView.leadingAnchor.constraint(equalTo: commentStack.leadingAnchor),
      commentTextView.trailingAnchor.constraint(equalTo: commentStack.trailingAnchor),
      commentTextView.widthAnchor.constraint(equalTo: commentTextView.heightAnchor, multiplier: 2)
    ])
  }

  private func makeSectionLabel(_ text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = UIFont(name: "GowunBatang-Bold", size: 15)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }

  private func makeRateRow() -> UIStackView {
    let rateData: [(tag: Int, title: String, image: String, selectedImage: String)] = [
      (5, "매우 맛있어요!", "star5_deselected", "star5"),
      (4, "맛있어요!", "star4_deselected", "star4"),
      (3, "괜찮아요", "star3_deselected", "star3"),
      (2, "별로에요", "star2_deselected", "star2"),
      (1, "너무 별로에요", "star1_deselected", "star1")
    ]

    let spacerLeft = UIView()
    spacerLeft.backgroundColor = .systemBackground
    let spacerRight = UIView()
    spacerRight.backgroundColor = .systemBackground

    var itemStacks: [UIView] = [spacerLeft]

    for data in rateData {
      let button = UIButton(type: .custom)
      button.tag = data.tag
      button.setImage(UIImage(named: data.image), for: .normal)
      button.setImage(UIImage(named: data.selectedImage), for: .selected)
      button.tintColor = UIColor(named: "OppositeColor")
      button.addTarget(self, action: #selector(onRate), for: .touchUpInside)
      button.translatesAutoresizingMaskIntoConstraints = false
      rateButtons.append(button)

      let label = UILabel()
      label.text = data.title
      label.font = .systemFont(ofSize: 9, weight: .semibold)
      label.textAlignment = .center
      label.translatesAutoresizingMaskIntoConstraints = false

      let stack = UIStackView(arrangedSubviews: [button, label])
      stack.axis = .vertical
      stack.spacing = 11
      stack.translatesAutoresizingMaskIntoConstraints = false
      stack.widthAnchor.constraint(equalTo: stack.heightAnchor, multiplier: 1.0 / 1.3).isActive = true

      itemStacks.append(stack)
    }

    itemStacks.append(spacerRight)

    let row = UIStackView(arrangedSubviews: itemStacks)
    row.axis = .horizontal
    row.spacing = 11
    row.translatesAutoresizingMaskIntoConstraints = false
    return row
  }

  private func updateRate(_ rate: Rate) {
    for button in rateButtons {
      button.isSelected = button.tag == rate.rawValue
    }
    viewModel.rate = rate.rawValue
  }

  @objc private func datePickerDone() {
    if let datePicker = dateTextField.inputView as? UIDatePicker {
      dateTextField.text = DateFormatter.selectDateFormat.string(from: datePicker.date)
    }
    dateTextField.resignFirstResponder()
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
  @objc private func onDone() {
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
      dismiss(animated: true)
    }
  }

  @objc private func onClose() {
    Analytics.logEvent("CANCEL_newRecord", parameters: nil)
    dismiss(animated: true)
  }

  @objc private func onAddImage() {
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
    present(alert, animated: true)
  }

  @objc private func onRate(_ sender: UIButton) {
    guard let rate = Rate(rawValue: sender.tag) else { return }
    updateRate(rate)
  }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension AddRecordViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      recordImageView.image = image
    }
    dismiss(animated: true)
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
    if textField == titleTextField {
      dateTextField.becomeFirstResponder()
    }
    return true
  }
}
