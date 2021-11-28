//
//  DatePickerViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/28.
//

import UIKit

class DatePickerViewController: UIViewController {

  // MARK: - UI
  @IBOutlet weak var datePicker: UIDatePicker!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
        super.viewDidLoad()
    datePicker.preferredDatePickerStyle  = .wheels
  }

}
