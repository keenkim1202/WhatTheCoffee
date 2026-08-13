import UIKit

/// 목록이 비어 보이는 이유를 알려주는 뷰.
/// 불러오는 중인지, 결과가 없는 건지, 실패한 건지 구분하지 않으면
/// 사용자는 모든 경우를 "고장"으로 받아들인다.
final class ListStatusView: UIView {

  enum State {
    case hidden
    case loading(String)
    case empty(String)
    case failed(AppError)
  }

  var onRetry: (() -> Void)?

  private let indicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .medium)
    indicator.hidesWhenStopped = true
    return indicator
  }()

  private let messageLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.GowunBatang(type: .regular, size: 15)
    label.textColor = .secondaryLabel
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()

  private let retryButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("다시 시도", for: .normal)
    button.setTitleColor(UIColor(named: "GreenSubColor"), for: .normal)
    button.titleLabel?.font = UIFont(name: "GowunBatang-Bold", size: 15)
    button.backgroundColor = UIColor(named: "GreenMainColor")
    button.layer.cornerRadius = 18
    button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
    button.isHidden = true
    return button
  }()

  private lazy var stack: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [indicator, messageLabel, retryButton])
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = 12
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  // MARK: - Init
  init() {
    super.init(frame: .zero)

    addSubview(stack)
    retryButton.addTarget(self, action: #selector(onRetryTapped), for: .touchUpInside)
    // 상태가 정해지기 전에는 아무것도 가리지 않는다.
    isHidden = true

    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: centerYAnchor),
      stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
      stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Display
  func apply(_ state: State) {
    switch state {
    case .hidden:
      isHidden = true
      indicator.stopAnimating()

    case .loading(let message):
      isHidden = false
      indicator.startAnimating()
      messageLabel.text = message
      retryButton.isHidden = true

    case .empty(let message):
      isHidden = false
      indicator.stopAnimating()
      messageLabel.text = message
      retryButton.isHidden = true

    case .failed(let error):
      isHidden = false
      indicator.stopAnimating()
      messageLabel.text = error.localizedDescription
      // 실패했을 때 무엇을 눌러야 할지 화면 안에 있어야 한다.
      retryButton.isHidden = false
    }
  }

  // MARK: - Action
  @objc private func onRetryTapped() {
    onRetry?()
  }
}
