import Foundation
import RealmSwift

final class RealmDataSource {
  let realm: Realm

  init(realm: Realm) {
    self.realm = realm
    print("Realm Location: ", realm.configuration.fileURL ?? "cannot find location.")
  }

  func objects<T: Object>(_ type: T.Type) -> Results<T> {
    return realm.objects(type)
  }

  func object<T: Object, K>(ofType type: T.Type, forPrimaryKey key: K) -> T? {
    return realm.object(ofType: type, forPrimaryKey: key)
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
