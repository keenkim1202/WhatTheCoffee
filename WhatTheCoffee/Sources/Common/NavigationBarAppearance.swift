import UIKit

/// 앱 전체의 네비게이션 바 모양을 한 곳에서 정한다.
/// appearance 프록시로 걸어두면 화면마다 따로 만든 UINavigationBar에도 그대로 적용된다.
enum NavigationBarAppearance {

  static func apply() {
    let appearance = UINavigationBarAppearance()
    // 기본값은 시스템이 배경을 흐리게 처리한다. 화면 배경과 이어지도록 같은 색으로 채운다.
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .appearanceColor
    appearance.shadowColor = .clear

    appearance.titleTextAttributes = [
      .font: UIFont(name: "GowunBatang-Bold", size: 17)!,
      .foregroundColor: UIColor.oppositeColor
    ]

    let button = UIBarButtonItemAppearance(style: .plain)
    button.normal.titleTextAttributes = buttonTitleAttributes(color: .orangeMainColor)
    button.highlighted.titleTextAttributes = buttonTitleAttributes(color: .orangeMainColor)
    button.disabled.titleTextAttributes = buttonTitleAttributes(color: .tertiaryLabel)

    appearance.buttonAppearance = button
    appearance.doneButtonAppearance = button
    appearance.backButtonAppearance = button

    let navigationBar = UINavigationBar.appearance()
    navigationBar.standardAppearance = appearance
    navigationBar.compactAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    navigationBar.compactScrollEdgeAppearance = appearance
    navigationBar.tintColor = .orangeMainColor
    // 콘텐츠가 바 아래로 지나갈 때 반투명 재질이 비치면 배경보다 밝은 띠로 보인다.
    navigationBar.isTranslucent = false
  }

  /// iOS 26은 바 버튼 뒤에 유리 재질 배경을 깔아준다. 앱의 평평한 톤과 어울리지 않아 끈다.
  /// appearance로는 제어할 수 없고 항목마다 지정해야 한다.
  static func hideSharedBackground(on items: [UIBarButtonItem]?) {
    guard #available(iOS 26.0, *), let items else { return }
    items.forEach { $0.hidesSharedBackground = true }
  }

  private static func buttonTitleAttributes(color: UIColor) -> [NSAttributedString.Key: Any] {
    return [
      .font: UIFont(name: "GowunBatang-Bold", size: 16)!,
      .foregroundColor: color
    ]
  }
}
