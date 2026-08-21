import AppIntents
import WidgetKit

/// 위젯에서 앱을 열지 않고 오늘의 커피를 한 잔 더 뽑는다.
/// 다음 날 자정이 되면 어차피 새로 뽑으므로 오늘 안에서만 유효하다.
struct RerollCoffeeIntent: AppIntent {
  static var title: LocalizedStringResource = "다시 추천"
  static var description = IntentDescription("오늘의 커피를 다시 뽑습니다.")

  func perform() async throws -> some IntentResult {
    TodayCoffee.reroll(from: RealmProvider.coffees())
    WidgetCenter.shared.reloadTimelines(ofKind: TodayCoffeeWidget.kind)
    return .result()
  }
}
