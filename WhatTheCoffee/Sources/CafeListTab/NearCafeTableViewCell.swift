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
    cafeImageView.layer.cornerRadius = CGFloat(8)
    nameLabel.text = row.name
    addressLabel.text = row.address
  }
  
}
