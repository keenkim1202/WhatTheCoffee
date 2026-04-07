import UIKit
import RealmSwift

// 커피 목록에 보일 커피 모델
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

