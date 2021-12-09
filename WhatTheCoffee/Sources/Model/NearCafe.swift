//
//  NearCafe.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/12/02.
//

import Foundation
import RealmSwift

// 커피 목록에 보일 커피 모델
class NearCafe: Object {
  @Persisted var name: String
  @Persisted var address: String
  @Persisted var latitude: Double
  @Persisted var longitude: Double
  @Persisted var placeUrl: String

  @Persisted(primaryKey: true) var _id: ObjectId
  
  convenience init(name: String, address: String, latitude: Double, longitude: Double, placeUrl: String) {
    self.init()
    self.name = name
    self.address = address
    self.latitude = latitude
    self.longitude = longitude
    self.placeUrl = placeUrl
  }
}
