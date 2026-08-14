import Foundation
import RealmSwift

final class RealmDataSource {
  let realm: Realm

  init(realm: Realm) {
    self.realm = realm
    print("Realm Location: ", realm.configuration.fileURL ?? "cannot find location.")
  }

  func objects<T: Object>(_ type: T.Type) -> Results<T> {
    refreshIfNeeded()
    return realm.objects(type)
  }

  func object<T: Object, K>(ofType type: T.Type, forPrimaryKey key: K) -> T? {
    refreshIfNeeded()
    return realm.object(ofType: type, forPrimaryKey: key)
  }

  /// 위젯은 다른 프로세스에서 같은 파일에 쓴다.
  /// 앱이 들고 있는 인스턴스는 갱신하기 전까지 그 쓰기를 보지 못해 예전 값을 돌려준다.
  private func refreshIfNeeded() {
    guard !realm.isInWriteTransaction else { return }
    realm.refresh()
  }

  func write(_ block: () -> Void) {
    try! realm.write {
      block()
    }
  }

  func add(_ object: Object) {
    write { realm.add(object) }
  }

  func delete(_ object: Object) {
    write { realm.delete(object) }
  }

  func create<T: Object>(_ type: T.Type, value: Any, update: Realm.UpdatePolicy) {
    write { realm.create(type, value: value, update: update) }
  }
}
