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
  @IBOutlet weak var cafeNameLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  
  func cellConfigure(row: NearCafe) {
    cafeImageView.layer.cornerRadius = CGFloat(8)
    cafeNameLabel.text = row.name
    addressLabel.text = row.address
    distanceLabel.text = "\(row.distance)m"
  }
  
}
