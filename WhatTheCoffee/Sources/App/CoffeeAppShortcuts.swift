import AppIntents

/// 앱을 열지 않고 오늘 방문을 남긴다.
/// 카페에 앉아 폰을 꺼내 앱을 열고 화면을 넘기는 것보다, 말 한마디가 짧다.
struct RecordCoffeeVisitIntent: AppIntent {
  static var title: LocalizedStringResource = "오늘 커피 기록"
  static var description = IntentDescription("가장 최근에 간 카페를 오늘 한 번 더 방문한 것으로 기록합니다.")

  /// 기록만 남기고 끝나므로 앱을 띄울 이유가 없다.
  static var openAppWhenRun = false

  func perform() async throws -> some IntentResult & ProvidesDialog {
    // 위젯 버튼과 같은 규칙이다. 새 기록을 만들지 않고 최근 기록에 방문을 더한다.
    guard let cafe = DIContainer().makeManageRecordsUseCase().addVisitToLatest() else {
      return .result(dialog: "아직 기록이 없어요. 앱에서 카페를 먼저 기록해주세요.")
    }
    return .result(dialog: "\(cafe.name) 방문을 기록했어요.")
  }
}

/// 시리와 단축어 앱에 노출되는 항목.
/// AppShortcutsProvider는 앱 타깃에 있어야 문구가 자동으로 잡힌다.
struct CoffeeAppShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: RecordCoffeeVisitIntent(),
      phrases: [
        "\(.applicationName)에 커피 기록",
        "\(.applicationName) 방문 기록",
        "Record a coffee in \(.applicationName)"
      ],
      shortTitle: "오늘 커피 기록",
      systemImageName: "cup.and.saucer.fill")
  }
}
