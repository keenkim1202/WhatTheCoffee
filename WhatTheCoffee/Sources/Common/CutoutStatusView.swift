import UIKit

/// 사진에 무엇이 적용됐는지 이미지 아래에 계속 보여준다.
/// 알림으로 알리면 확인을 누르는 순간 사라져 누끼인지 원본인지 알 방법이 없다.
final class CutoutStatusView: UIStackView {

  var onChange: (() -> Void)?

  private let statusLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.GowunBatang(type: .regular, size: 12)
    label.textColor = .secondaryLabel
    label.numberOfLines = 2
    return label
  }()

  private let changeButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("변경", for: .normal)
    button.setTitleColor(UIColor(named: "GreenMainColor"), for: .normal)
    button.titleLabel?.font = UIFont(name: "GowunBatang-Bold", size: 12)
    button.setContentHuggingPriority(.required, for: .horizontal)
    return button
  }()

  // MARK: - Init
  init() {
    super.init(frame: .zero)

    addArrangedSubview(statusLabel)
    addArrangedSubview(changeButton)
    axis = .horizontal
    spacing = 8
    alignment = .center
    isHidden = true
    changeButton.addTarget(self, action: #selector(onChangeTapped), for: .touchUpInside)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Display
  func show(_ subject: SubjectCutout.Subject, canChange: Bool) {
    statusLabel.text = subject.isCutout ? "배경을 지운 이미지 · \(subject.title)" : "원본 이미지"
    changeButton.isHidden = !canChange
    isHidden = false
  }

  func showFailure(_ error: Error) {
    statusLabel.text = Self.reason(for: error)
    changeButton.isHidden = true
    isHidden = false
  }

  func clear() {
    isHidden = true
  }

  private static func reason(for error: Error) -> String {
    switch error {
    case SubjectCutout.Failure.subjectNotFound:
      return "원본 이미지 · 사진에서 피사체를 찾지 못했어요"
    case SubjectCutout.Failure.unreadableImage:
      return "원본 이미지 · 사진을 분석할 수 없어요"
    default:
      return "원본 이미지 · 이 기기에서는 배경을 지울 수 없어요"
    }
  }

  // MARK: - Action
  @objc private func onChangeTapped() {
    onChange?()
  }
}
