//
//  DateFormatter++Extension.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/26.
//

import Foundation

extension DateFormatter {
  static var visitDateFormat: DateFormatter {
    let date = DateFormatter()
    date.dateFormat = "yyyy/MM/dd"
    return date
  }
}
