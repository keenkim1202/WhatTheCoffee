import Foundation

/// 통계에서 눌러 들어갈 때 "어떤 기록을 볼 것인가"를 담는다.
/// 네 진입점이 같은 화면을 쓰고 조건만 다르다.
enum RecordFilter {
  case month(year: Int, month: Int)
  case cafe(name: String)
  case rate(Int)
  case coffee(name: String)

  var title: String {
    switch self {
    case .month(_, let month): return "\(month)월에 간 곳"
    case .cafe(let name): return name
    case .rate(let rate): return "\(rate)점을 준 곳"
    case .coffee(let name): return name + "를 마신 곳"
    }
  }

  /// 조건에 맞는 기록만 남긴다.
  func matches(_ cafe: CafeEntity, calendar: Calendar = .current) -> Bool {
    switch self {
    case .month(let year, let month):
      // 방문마다 날짜가 남으므로 그달에 간 적이 있으면 포함한다.
      return cafe.visitDates.contains { date in
        let components = calendar.dateComponents([.year, .month], from: date)
        return components.year == year && components.month == month
      }

    case .cafe(let name):
      return cafe.name == name

    case .rate(let rate):
      return cafe.rate == rate

    case .coffee(let name):
      return cafe.coffeeName == name
    }
  }

  /// 목록에 곁들일 한 줄. 무엇을 기준으로 추린 것인지 화면에 남겨둔다.
  func summary(count: Int) -> String {
    switch self {
    case .month(let year, let month): return "\(year)년 \(month)월 · 기록 \(count)개"
    case .cafe: return "기록 \(count)개"
    case .rate: return "기록 \(count)개"
    case .coffee: return "기록 \(count)개"
    }
  }
}
