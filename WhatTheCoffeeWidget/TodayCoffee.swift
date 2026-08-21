import Foundation

/// 오늘 보여줄 커피 한 잔을 고르는 규칙.
/// 위젯은 하루에도 여러 번 다시 그려지므로, 그릴 때마다 뽑으면 커피가 계속 바뀐다.
/// 그래서 날짜를 씨앗으로 삼아 같은 날에는 같은 답이 나오게 하고,
/// 버튼으로 다시 뽑은 답만 오늘 하루 동안 씨앗보다 앞세운다.
enum TodayCoffee {
  private static let dayKey = "todayCoffee.day"
  private static let pickKey = "todayCoffee.pick"

  private static var store: UserDefaults? {
    return UserDefaults(suiteName: SharedImageStore.appGroupID)
  }

  /// 오늘의 커피. 추천 목록이 비어 있으면 nil이다.
  static func pick(from coffees: [CoffeeSnapshot],
                   date: Date = Date(),
                   calendar: Calendar = .current) -> CoffeeSnapshot? {
    guard !coffees.isEmpty else { return nil }
    let day = dayNumber(of: date, calendar: calendar)

    // 지워진 커피가 저장돼 있을 수 있다. 그때는 날짜로 뽑은 답으로 돌아간다.
    if let chosen = storedPick(day: day), let coffee = coffees.first(where: { $0.id == chosen }) {
      return coffee
    }
    return coffees[index(day: day, count: coffees.count)]
  }

  /// 위젯 버튼으로 한 잔 더 뽑는다.
  /// 눌렀는데 같은 커피가 그대로 있으면 고장으로 읽히므로 지금 잔을 뺀 나머지에서 고른다.
  static func reroll(from coffees: [CoffeeSnapshot],
                     date: Date = Date(),
                     calendar: Calendar = .current) {
    guard let store, coffees.count > 1 else { return }
    let current = pick(from: coffees, date: date, calendar: calendar)
    guard let next = coffees.filter({ $0.id != current?.id }).randomElement() else { return }

    store.set(dayNumber(of: date, calendar: calendar), forKey: dayKey)
    store.set(next.id, forKey: pickKey)
  }

  /// 버튼으로 뽑아둔 오늘의 답. 날이 바뀌면 없는 것으로 본다.
  private static func storedPick(day: Int) -> String? {
    guard let store, store.integer(forKey: dayKey) == day else { return nil }
    return store.string(forKey: pickKey)
  }

  /// 자정을 기준으로 하루를 센다.
  private static func dayNumber(of date: Date, calendar: Calendar) -> Int {
    return Int(calendar.startOfDay(for: date).timeIntervalSince1970 / 86_400)
  }

  /// 날짜를 목록의 자리로 옮긴다.
  /// 날짜를 그냥 목록 길이로 나누면 하루가 지날 때마다 바로 다음 칸으로 밀려 무작위로 보이지 않는다.
  private static func index(day: Int, count: Int) -> Int {
    guard count > 1 else { return 0 }
    var mixed = UInt64(bitPattern: Int64(day)) &+ 0x9E3779B97F4A7C15
    mixed = (mixed ^ (mixed >> 30)) &* 0xBF58476D1CE4E5B9
    mixed = (mixed ^ (mixed >> 27)) &* 0x94D049BB133111EB
    mixed = mixed ^ (mixed >> 31)
    return Int(mixed % UInt64(count))
  }
}
