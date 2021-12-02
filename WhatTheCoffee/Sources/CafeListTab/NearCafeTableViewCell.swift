//
//  NearCafeTableViewCell.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/12/02.
//

import UIKit

class NearCafeTableViewCell: UITableViewCell {

  static let identifier = "nearCafeCell"
  
  @IBOutlet weak var cafeImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  
  func cellConfigure(row: NearCafe) {
    nameLabel.text = row.name
    addressLabel.text = row.address
  }
  
}
