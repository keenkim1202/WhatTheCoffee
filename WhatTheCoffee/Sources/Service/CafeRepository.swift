//
//  CafeRepository.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/25.
//

import Foundation

import Foundation
import Realm
import RealmSwift

protocol CafeRepositoryType {
  var count: Int { get }

  func add(item: Cafe)
  func update(item: Cafe, new: Cafe)
  func remove(item: Cafe)
  func fetch() -> [Cafe]
}

final class CafeRepository: CafeRepositoryType {

  private let realm: Realm

  init(realm: Realm) {
    self.realm = realm
    print("Realm Location: ", realm.configuration.fileURL ?? "cannot find locaation.")
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
                "date": Date()
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
      .sorted(byKeyPath: "name", ascending: false)
      .map { $0 }
  }
  
}
