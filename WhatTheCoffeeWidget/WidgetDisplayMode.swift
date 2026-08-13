import AppIntents

/// 위젯이 어느 카페를 골라 보여줄지.
/// 위젯을 길게 눌러 편집하면 사용자가 직접 고른다.
enum WidgetDisplayMode: String, AppEnum {
  /// 가장 마지막에 간 곳.
  case recent
  /// 지금 위치에서 가장 가까운, 전에 가본 곳.
  case nearest

  static var typeDisplayRepresentation: TypeDisplayRepresentation {
    return TypeDisplayRepresentation(name: "보여줄 카페")
  }

  static var caseDisplayRepresentations: [WidgetDisplayMode: DisplayRepresentation] {
    return [
      .recent: DisplayRepresentation(title: "최근 방문", subtitle: "가장 마지막에 간 곳"),
      .nearest: DisplayRepresentation(title: "가까운 곳", subtitle: "지금 위치에서 가까운, 전에 간 곳")
    ]
  }
}

struct SelectDisplayModeIntent: WidgetConfigurationIntent {
  static var title: LocalizedStringResource = "커피 방문 기록"
  static var description = IntentDescription("위젯에 어느 카페를 보여줄지 고릅니다.")

  @Parameter(title: "보여줄 카페", default: .recent)
  var mode: WidgetDisplayMode

  init() {}

  init(mode: WidgetDisplayMode) {
    self.mode = mode
  }
}
