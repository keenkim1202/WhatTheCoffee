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

  @Persisted(primaryKey: true) var _id: ObjectId

  convenience init(name: String, comment: String?, rate: Int) {
    self.init()
    self.name = name
    self.visitDate = Date()
    self.comment = comment
    self.rate = rate
  }

  convenience init(name: String, visitDate: Date, comment: String?, rate: Int, latitude: Double?, longitude: Double?, address: String?) {
    self.init()
    self.name = name
    self.visitDate = visitDate
    self.comment = comment
    self.rate = rate
    self.latitude = latitude
    self.longitude = longitude
    self.address = address
    self.isClosed = false
  }
}
