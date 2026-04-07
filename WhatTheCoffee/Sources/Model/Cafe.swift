import UIKit
import RealmSwift

// 커피 기록에 쓰일 카페 모델
class Cafe: Object {
  @Persisted var name: String
  @Persisted var visitDate: Date
  @Persisted var comment: String?
  @Persisted var rate: Int
  
  @Persisted(primaryKey: true) var _id: ObjectId
  
  convenience init(name: String, comment: String?, rate: Int) {
    self.init()
    self.name = name
    self.visitDate = Date()
    self.comment = comment
    self.rate = rate
  }
  
  convenience init(name: String, visitDate: Date, comment: String?, rate: Int) {
    self.init()
    self.name = name
    self.visitDate = visitDate
    self.comment = comment
    self.rate = rate
  }
}
