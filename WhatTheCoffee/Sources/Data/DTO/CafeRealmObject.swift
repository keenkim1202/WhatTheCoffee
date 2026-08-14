import RealmSwift
import Foundation

class Cafe: Object {
  @Persisted var name: String
  @Persisted var visitDate: Date
  @Persisted var comment: String?
  @Persisted var rate: Int
  @Persisted var latitude: Double?
  @Persisted var longitude: Double?
  @Persisted var isClosed: Bool
  @Persisted var address: String?
  /// 같은 방문 기록을 몇 번 반복했는지. 기본은 한 번.
  @Persisted var visitCount: Int = 1

  @Persisted(primaryKey: true) var _id: ObjectId

  convenience init(name: String, comment: String?, rate: Int) {
    self.init()
    self.name = name
    self.visitDate = Date()
    self.comment = comment
    self.rate = rate
  }

  convenience init(name: String, visitDate: Date, comment: String?, rate: Int, latitude: Double?, longitude: Double?, address: String?, visitCount: Int = 1) {
    self.init()
    self.name = name
    self.visitDate = visitDate
    self.comment = comment
    self.rate = rate
    self.latitude = latitude
    self.longitude = longitude
    self.address = address
    self.visitCount = max(1, visitCount)
    self.isClosed = false
  }
}
