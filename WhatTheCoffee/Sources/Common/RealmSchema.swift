import Foundation
import RealmSwift

/// 앱과 위젯이 같은 Realm 파일을 열기 때문에 버전과 마이그레이션도 같아야 한다.
/// 한쪽만 고치면 먼저 여는 쪽이 다르게 이전해 버린다.
enum RealmSchema {
  static let version: UInt64 = 5

  static let migrationBlock: MigrationBlock = { migration, oldSchemaVersion in
    // 횟수만 세던 것을 방문마다 날짜를 남기도록 바꾼다.
    // 예전 기록은 날짜를 하나밖에 모르므로 그 날짜를 횟수만큼 채운다.
    // 지난 방문의 실제 날짜는 되살릴 수 없지만 총 횟수는 그대로 보존된다.
    if oldSchemaVersion < 5 {
      migration.enumerateObjects(ofType: "Cafe") { old, new in
        let visitDate = old?["visitDate"] as? Date ?? Date()
        new?["visitDates"] = Array(repeating: visitDate, count: visitCount(of: old, at: oldSchemaVersion))
      }
    }
  }

  /// visitCount는 스키마 4에서 생겼다가 5에서 없어졌다.
  /// Realm은 스키마에 없는 이름을 읽기만 해도 예외를 던지므로 버전을 보고 물어야 한다.
  private static func visitCount(of old: MigrationObject?, at oldSchemaVersion: UInt64) -> Int {
    guard oldSchemaVersion >= 4 else { return 1 }
    return max(1, (old?["visitCount"] as? Int) ?? 1)
  }
}
