//
//  UITextField++Extension.swift.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/28.
//

import UIKit

extension UITextField {
  func setDatePicker(target: Any, selector: Selector) {
    let SCwidth = self.bounds.width
    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: SCwidth, height: 216))
    datePicker.datePickerMode = .date
    datePicker.locale = Locale(identifier: "ko-KR")
    datePicker.preferredDatePickerStyle  = .wheels
    datePicker.maximumDate = Date()
    self.inputView = datePicker
    
    let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: SCwidth, height: 44.0))
    let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let cancel = UIBarButtonItem(title: "닫기", style: .plain, target: nil, action: #selector(tapCancel))
    let barButton = UIBarButtonItem(title: "완료", style: .plain, target: target, action: selector)
    toolBar.setItems([cancel, flexible, barButton], animated: false)
    self.inputAccessoryView = toolBar
    
  }
  
  @objc func tapCancel() {
    self.resignFirstResponder()
  }
}


