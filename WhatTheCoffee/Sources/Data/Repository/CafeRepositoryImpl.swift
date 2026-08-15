import Foundation
import RealmSwift
import WidgetKit

final class CafeRepositoryImpl: CafeRepositoryProtocol {

  private let dataSource: RealmDataSource

  init(dataSource: RealmDataSource) {
    self.dataSource = dataSource
  }

  var count: Int {
    return dataSource.objects(Cafe.self).count
  }

  @discardableResult
  func add(name: String, visitDate: Date = Date(), comment: String?, rate: Int, latitude: Double?, longitude: Double?, address: String?, visitDates: [Date], coffeeName: String?, coffeeId: String?) -> CafeEntity {
    let object = Cafe(name: name, visitDate: visitDate, comment: comment, rate: rate, latitude: latitude, longitude: longitude, address: address, visitDates: visitDates, coffeeName: coffeeName, coffeeId: coffeeId)
    dataSource.add(object)
    reloadWidget()
    return CafeMapper.toEntity(object)
  }

  func update(id: String, name: String, visitDate: Date, comment: String?, rate: Int, latitude: Double?, longitude: Double?, address: String?, visitDates: [Date], coffeeName: String?, coffeeId: String?) {
    guard let objectId = try? ObjectId(string: id) else { return }
    // 방문 날짜가 진실이고 visitDate는 그중 가장 늦은 날이어야 정렬이 맞는다.
    let dates = (visitDates.isEmpty ? [visitDate] : visitDates).sorted()
    var value: [String: Any] = ["_id": objectId, "name": name, "visitDate": dates.last ?? visitDate, "comment": comment ?? "", "rate": rate, "visitDates": dates, "coffeeName": coffeeName as Any, "coffeeId": coffeeId as Any]
    if let latitude { value["latitude"] = latitude }
    if let longitude { value["longitude"] = longitude }
    if let address { value["address"] = address }
    dataSource.create(Cafe.self, value: value, update: .modified)
    reloadWidget()
  }

  func updateClosedStatus(id: String, isClosed: Bool) {
    guard let objectId = try? ObjectId(string: id) else { return }
    dataSource.create(
      Cafe.self,
      value: ["_id": objectId, "isClosed": isClosed],
      update: .modified)
  }

  func remove(id: String) {
    guard let objectId = try? ObjectId(string: id) else { return }
    guard let object = dataSource.object(ofType: Cafe.self, forPrimaryKey: objectId) else { return }
    dataSource.delete(object)
    reloadWidget()
  }

  /// 위젯은 방문 수와 최근 방문 카페를 보여주므로, 그 둘을 바꾸는 쓰기 뒤에만 갱신한다.
  /// 폐점 여부는 위젯에 나오지 않아 updateClosedStatus에서는 부르지 않는다.
  private func reloadWidget() {
    WidgetCenter.shared.reloadAllTimelines()
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
