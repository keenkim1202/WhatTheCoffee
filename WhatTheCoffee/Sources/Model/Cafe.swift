//
//  Cafe.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/17.
//

import UIKit

// 커피 기록에 쓰일 카페 모델
struct Cafe {
  var name: String
  var visitDate: Date
  var comment: String
  var rate: Rate
  var cafeImage: UIImage
}
