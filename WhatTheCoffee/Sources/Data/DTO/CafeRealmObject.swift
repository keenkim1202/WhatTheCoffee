import RealmSwift
import Foundation

class Cafe: Object {
  @Persisted var name: String
  /// 가장 최근 방문일. Realm이 정렬할 수 있도록 따로 들고 있는다.
  @Persisted var visitDate: Date
  @Persisted var comment: String?
  @Persisted var rate: Int
  @Persisted var latitude: Double?
  @Persisted var longitude: Double?
  @Persisted var isClosed: Bool
  @Persisted var address: String?
  /// 방문한 날들. 이쪽이 진짜 기록이고 visitDate는 이 중 가장 늦은 날이다.
  @Persisted var visitDates: List<Date>

  @Persisted(primaryKey: true) var _id: ObjectId

  /// 기록이 하나도 없는 상태는 있을 수 없으므로 최소 1로 본다.
  var visitCount: Int {
    return max(1, visitDates.count)
  }

  convenience init(name: String, comment: String?, rate: Int) {
    self.init()
    self.name = name
    self.visitDate = Date()
    self.comment = comment
    self.rate = rate
    self.visitDates.append(self.visitDate)
  }

  convenience init(name: String, visitDate: Date, comment: String?, rate: Int, latitude: Double?, longitude: Double?, address: String?, visitDates: [Date] = []) {
    self.init()
    self.name = name
    self.comment = comment
    self.rate = rate
    self.latitude = latitude
    self.longitude = longitude
    self.address = address
    self.isClosed = false

    let dates = visitDates.isEmpty ? [visitDate] : visitDates.sorted()
    self.visitDates.append(objectsIn: dates)
    self.visitDate = dates.last ?? visitDate
  }
}
