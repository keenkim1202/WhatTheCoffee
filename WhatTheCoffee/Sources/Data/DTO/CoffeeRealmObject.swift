import RealmSwift
import Foundation

class Coffee: Object {
  @Persisted var name: String
  @Persisted var date: Date

  @Persisted(primaryKey: true) var _id: ObjectId

  convenience init(name: String) {
    self.init()
    self.name = name
    self.date = Date()
  }
}
