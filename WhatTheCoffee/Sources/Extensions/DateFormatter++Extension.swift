//
//  DateFormatter++Extension.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/26.
//

import Foundation

extension DateFormatter {
  static var visitDateFormat: DateFormatter {
    let df = DateFormatter()
    df.dateFormat = "yyyy/MM/dd"
    return df
  }
  
  static var selectDateFormat: DateFormatter {
    let df = DateFormatter()
    df.dateFormat = "yyyy년 MM월 dd일"
    return df
  }
}
