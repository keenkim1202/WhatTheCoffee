//
//  Coffee.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/17.
//

import UIKit
import RealmSwift

class Coffee: Object {
  @Persisted var name: String

  @Persisted(primaryKey: true) var _id: ObjectId
  
  convenience init(name: String) {
    self.init()
    self.name = name
  }
}

