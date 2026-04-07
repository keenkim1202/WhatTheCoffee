import Foundation
import RealmSwift

final class CoffeeRepositoryImpl: CoffeeRepositoryProtocol {

  private let dataSource: RealmDataSource

  init(dataSource: RealmDataSource) {
    self.dataSource = dataSource
  }

  var count: Int {
    return dataSource.objects(Coffee.self).count
  }

  @discardableResult
  func add(name: String) -> CoffeeEntity {
    let object = Coffee(name: name)
    dataSource.add(object)
    return CoffeeMapper.toEntity(object)
  }

  func update(id: String, name: String) {
    guard let objectId = try? ObjectId(string: id) else { return }
    dataSource.create(
      Coffee.self,
      value: ["_id": objectId, "name": name, "date": Date()],
      update: .modified)
  }

  func remove(id: String) {
    guard let objectId = try? ObjectId(string: id) else { return }
    guard let object = dataSource.object(ofType: Coffee.self, forPrimaryKey: objectId) else { return }
    dataSource.delete(object)
  }

  func fetch() -> [CoffeeEntity] {
    return dataSource.objects(Coffee.self)
      .map { CoffeeMapper.toEntity($0) }
      .sorted(by: { $0.name < $1.name })
  }

  func isContain(id: String) -> Bool {
    guard let objectId = try? ObjectId(string: id) else { return false }
    return dataSource.object(ofType: Coffee.self, forPrimaryKey: objectId) != nil
  }
}
