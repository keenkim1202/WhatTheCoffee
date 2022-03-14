//
//  CafeRepository.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/25.
//

import Foundation
import Realm
import RealmSwift

protocol CafeRepositoryType {
  var count: Int { get }
  
  func add(item: Cafe)
  func update(item: Cafe, new: Cafe)
  func remove(item: Cafe)
  func fetch() -> [Cafe]
  func search(query: String) -> Results<Cafe>
}

final class CafeRepository: CafeRepositoryType {
  
  private let realm: Realm
  
  init(realm: Realm) {
    self.realm = realm
  }
  
  var count: Int {
    return realm.objects(Cafe.self).count
  }
  
  func add(item: Cafe) {
    try! realm.write {
      realm.add(item)
    }
  }
  
  func update(item: Cafe, new: Cafe) {
    try! realm.write {
      realm.create(
        Cafe.self,
        value: ["_id": item._id,
                "name": new.name,
                "visitDate": new.visitDate,
                "comment": new.comment ?? "",
                "rate": new.rate
               ],
        update: .modified
      )
    }
  }
  
  func remove(item: Cafe) {
    try! realm.write {
      realm.delete(item)
    }
  }
  
  func fetch() -> [Cafe] {
    return realm.objects(Cafe.self)
      .map { $0 }
      .sorted(by: {$0.visitDate > $1.visitDate})
  }
  
  func search(query: String) -> Results<Cafe> {
    let search = realm.objects(Cafe.self)
      .filter("name CONTAINS[c] '\(query)' OR comment CONTAINS[c] '\(query)'")
    return search.sorted(byKeyPath: "visitDate", ascending: false)
  }
}
