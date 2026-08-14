import AppIntents
import WidgetKit

/// 위젯에서 앱을 열지 않고 최근 카페를 한 번 더 방문한 것으로 기록한다.
/// 별점은 직전 방문과 같은 값을 쓴다. 위젯에서 별점을 고를 방법이 없고,
/// "한 잔 더"는 같은 경험을 반복한다는 뜻에 가깝다. 앱에서 언제든 고칠 수 있다.
struct AddVisitIntent: AppIntent {
  static var title: LocalizedStringResource = "한 잔 더 기록"
  static var description = IntentDescription("최근 방문한 카페를 오늘 한 번 더 방문한 것으로 기록합니다.")

  @Parameter(title: "카페 이름")
  var name: String

  init() {
    self.name = ""
  }

  init(name: String) {
    self.name = name
  }

  func perform() async throws -> some IntentResult {
    RealmProvider.addVisit(cafeNamed: name)
    WidgetCenter.shared.reloadAllTimelines()
    return .result()
  }
}
