import RealmSwift

/// 앱과 위젯이 같은 Realm 파일을 열기 때문에 버전과 마이그레이션도 같아야 한다.
/// 한쪽만 고치면 먼저 여는 쪽이 다르게 이전해 버린다.
enum RealmSchema {
  static let version: UInt64 = 4

  static let migrationBlock: MigrationBlock = { migration, oldSchemaVersion in
    // visitCount는 새로 생긴 값이라 기존 기록은 0으로 채워진다.
    // 이미 남긴 기록은 최소 한 번은 간 것이므로 1로 올린다.
    if oldSchemaVersion < 4 {
      migration.enumerateObjects(ofType: "Cafe") { _, new in
        new?["visitCount"] = 1
      }
    }
  }
}
