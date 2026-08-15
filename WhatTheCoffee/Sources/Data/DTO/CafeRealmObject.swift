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
  /// 그 카페에서 마신 커피 이름. 커피 목록에서 지워져도 기록은 남아야 해서 참조가 아니라 이름으로 둔다.
  @Persisted var coffeeName: String?
  /// 커피 사진을 찾기 위한 값. 커피가 지워지면 사진도 없어지므로 이름으로 물러난다.
  @Persisted var coffeeId: String?

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

  convenience init(name: String, visitDate: Date, comment: String?, rate: Int, latitude: Double?, longitude: Double?, address: String?, visitDates: [Date] = [], coffeeName: String? = nil, coffeeId: String? = nil) {
    self.init()
    self.name = name
    self.comment = comment
    self.rate = rate
    self.latitude = latitude
    self.longitude = longitude
    self.address = address
    self.isClosed = false
    self.coffeeName = coffeeName
    self.coffeeId = coffeeId

    let dates = visitDates.isEmpty ? [visitDate] : visitDates.sorted()
    self.visitDates.append(objectsIn: dates)
    self.visitDate = dates.last ?? visitDate
  }
}
