//
//  Environment.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/22.
//

import Foundation

protocol Environment {
  var coffeeRepository: CoffeeRepository { get }
}

final class AppEnvironment: Environment {
  var coffeeRepository: CoffeeRepository
  
  init(coffeeRepository: CoffeeRepository) {
    self.coffeeRepository = coffeeRepository
  }
}
