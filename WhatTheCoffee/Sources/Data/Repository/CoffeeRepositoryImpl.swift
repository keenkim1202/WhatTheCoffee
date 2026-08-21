import Foundation
import RealmSwift
import WidgetKit

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
    reloadWidget()
    return CoffeeMapper.toEntity(object)
  }

  func update(id: String, name: String) {
    guard let objectId = try? ObjectId(string: id) else { return }
    dataSource.create(
      Coffee.self,
      value: ["_id": objectId, "name": name, "date": Date()],
      update: .modified)
    reloadWidget()
  }

  func remove(id: String) {
    guard let objectId = try? ObjectId(string: id) else { return }
    guard let object = dataSource.object(ofType: Coffee.self, forPrimaryKey: objectId) else { return }
    dataSource.delete(object)
    reloadWidget()
  }

  /// 오늘의 커피 위젯이 목록에서 한 잔을 골라 보여주므로, 목록을 바꾸는 쓰기 뒤에 갱신한다.
  /// 위젯 이름은 위젯 타깃에만 있어 CafeRepositoryImpl과 같이 전체를 다시 그린다.
  private func reloadWidget() {
    WidgetCenter.shared.reloadAllTimelines()
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
