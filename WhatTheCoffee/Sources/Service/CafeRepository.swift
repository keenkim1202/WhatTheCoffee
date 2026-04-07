import Foundation
import RealmSwift

final class CafeRepository: CafeRepositoryProtocol {

  private let realm: Realm

  init(realm: Realm) {
    self.realm = realm
  }

  var count: Int {
    return realm.objects(Cafe.self).count
  }

  @discardableResult
  func add(name: String, visitDate: Date = Date(), comment: String?, rate: Int) -> CafeEntity {
    let object = Cafe(name: name, visitDate: visitDate, comment: comment, rate: rate)
    try! realm.write {
      realm.add(object)
    }
    return CafeMapper.toEntity(object)
  }

  func update(id: String, name: String, visitDate: Date, comment: String?, rate: Int) {
    guard let objectId = try? ObjectId(string: id) else { return }
    try! realm.write {
      realm.create(
        Cafe.self,
        value: ["_id": objectId, "name": name, "visitDate": visitDate, "comment": comment ?? "", "rate": rate],
        update: .modified)
    }
  }

  func remove(id: String) {
    guard let objectId = try? ObjectId(string: id) else { return }
    guard let object = realm.object(ofType: Cafe.self, forPrimaryKey: objectId) else { return }
    try! realm.write {
      realm.delete(object)
    }
  }

  func fetch() -> [CafeEntity] {
    return realm.objects(Cafe.self)
      .sorted(byKeyPath: "visitDate", ascending: false)
      .map { CafeMapper.toEntity($0) }
  }

  func search(query: String) -> [CafeEntity] {
    return realm.objects(Cafe.self)
      .filter("name CONTAINS[c] %@ OR comment CONTAINS[c] %@", query, query)
      .sorted(byKeyPath: "visitDate", ascending: false)
      .map { CafeMapper.toEntity($0) }
  }
}
