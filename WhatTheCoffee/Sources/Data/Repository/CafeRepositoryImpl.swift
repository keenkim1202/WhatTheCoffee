import Foundation
import RealmSwift

final class CafeRepositoryImpl: CafeRepositoryProtocol {

  private let dataSource: RealmDataSource

  init(dataSource: RealmDataSource) {
    self.dataSource = dataSource
  }

  var count: Int {
    return dataSource.objects(Cafe.self).count
  }

  @discardableResult
  func add(name: String, visitDate: Date = Date(), comment: String?, rate: Int) -> CafeEntity {
    let object = Cafe(name: name, visitDate: visitDate, comment: comment, rate: rate)
    dataSource.add(object)
    return CafeMapper.toEntity(object)
  }

  func update(id: String, name: String, visitDate: Date, comment: String?, rate: Int) {
    guard let objectId = try? ObjectId(string: id) else { return }
    dataSource.create(
      Cafe.self,
      value: ["_id": objectId, "name": name, "visitDate": visitDate, "comment": comment ?? "", "rate": rate],
      update: .modified)
  }

  func remove(id: String) {
    guard let objectId = try? ObjectId(string: id) else { return }
    guard let object = dataSource.object(ofType: Cafe.self, forPrimaryKey: objectId) else { return }
    dataSource.delete(object)
  }

  func fetch() -> [CafeEntity] {
    return dataSource.objects(Cafe.self)
      .sorted(byKeyPath: "visitDate", ascending: false)
      .map { CafeMapper.toEntity($0) }
  }

  func search(query: String) -> [CafeEntity] {
    return dataSource.objects(Cafe.self)
      .filter("name CONTAINS[c] %@ OR comment CONTAINS[c] %@", query, query)
      .sorted(byKeyPath: "visitDate", ascending: false)
      .map { CafeMapper.toEntity($0) }
  }
}
