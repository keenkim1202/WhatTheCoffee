//
//  UIAlert++Extension.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/23.
//

import UIKit

// TODO: 상황에 따라 alert문 케이스 나누기
// TODO: 커피기록 삭제시, 정말 삭제할 것인지 alert 띄우기

extension UIAlertController {
  enum ContentType: String {
    case error = "⚠️ 오류 🤯"
  }
  
  static func show(_ presentedHost: UIViewController,
                   contentType: ContentType,
                   message: String) {
    let alert = UIAlertController(
      title: contentType.rawValue,
      message: message,
      preferredStyle: .alert)
    let okAction = UIAlertAction(
      title: "확인", style: .default, handler: nil)
    alert.addAction(okAction)
    presentedHost.present(alert, animated: true, completion: nil)
  }
}
