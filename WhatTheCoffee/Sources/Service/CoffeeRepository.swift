//
//  RepositoryServiceType.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/17.
//

// realm에 프로젝트 데이터를 관리하기 위한 프로토콜 & 함수들을 작성.

import Foundation
import Realm
import RealmSwift

protocol CoffeeRepositoryType {
  var count: Int { get }

  func add(item: Coffee)
  func update(item: Coffee, new: Coffee)
  func remove(item: Coffee)
  func fetch() -> [Coffee]
}

final class CoffeeRepository: CoffeeRepositoryType {

  private let realm: Realm

  init(realm: Realm) {
    self.realm = realm
    print("Realm Location: ", realm.configuration.fileURL ?? "cannot find locaation.")
  }

  var count: Int {
    return realm.objects(Coffee.self).count
  }

  func add(item: Coffee) {
    try! realm.write {
      realm.add(item)
    }
  }

  func update(item: Coffee, new: Coffee) {
    try! realm.write {
      realm.create(
        Coffee.self,
        value: ["_id": item._id,
                "name": new.name,
                "date": Date()
                ],
        update: .modified
      )
    }
  }

  func remove(item: Coffee) {
    try! realm.write {
      realm.delete(item)
    }
  }

  func fetch() -> [Coffee] {
    return realm.objects(Coffee.self)
      .sorted(byKeyPath: "name", ascending: false)
      .map { $0 }
  }
  
}
