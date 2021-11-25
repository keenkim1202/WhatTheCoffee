//
//  Cafe.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/17.
//

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
    self.comment = comment
    self.rate = rate
    self.visitDate = Date()
  }
}
