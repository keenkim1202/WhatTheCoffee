import Foundation

extension DateFormatter {
  static var visitDateFormat: DateFormatter {
    let df = DateFormatter()
    df.locale = Locale(identifier: "ko-KR")
    df.timeZone = .autoupdatingCurrent
    df.dateFormat = "yyyy/MM/dd"
    return df
  }
  
  static var selectDateFormat: DateFormatter {
    let df = DateFormatter()
    df.locale = Locale(identifier: "ko-KR")
    df.timeZone = .autoupdatingCurrent
    df.dateFormat = "yyyy년 MM월 dd일"
    return df
  }
}
