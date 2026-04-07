import Foundation
import RealmSwift

final class CoffeeRepository: CoffeeRepositoryProtocol {

  private let realm: Realm

  init(realm: Realm) {
    self.realm = realm
    print("Realm Location: ", realm.configuration.fileURL ?? "cannot find location.")
  }

  var count: Int {
    return realm.objects(Coffee.self).count
  }

  @discardableResult
  func add(name: String) -> CoffeeEntity {
    let object = Coffee(name: name)
    try! realm.write {
      realm.add(object)
    }
    return CoffeeMapper.toEntity(object)
  }

  func update(id: String, name: String) {
    guard let objectId = try? ObjectId(string: id) else { return }
    try! realm.write {
      realm.create(
        Coffee.self,
        value: ["_id": objectId, "name": name, "date": Date()],
        update: .modified)
    }
  }

  func remove(id: String) {
    guard let objectId = try? ObjectId(string: id) else { return }
    guard let object = realm.object(ofType: Coffee.self, forPrimaryKey: objectId) else { return }
    try! realm.write {
      realm.delete(object)
    }
  }

  func fetch() -> [CoffeeEntity] {
    return realm.objects(Coffee.self)
      .map { CoffeeMapper.toEntity($0) }
      .sorted(by: { $0.name < $1.name })
  }

  func isContain(id: String) -> Bool {
    guard let objectId = try? ObjectId(string: id) else { return false }
    return realm.object(ofType: Coffee.self, forPrimaryKey: objectId) != nil
  }
}
