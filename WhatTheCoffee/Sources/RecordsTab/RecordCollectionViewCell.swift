//
//  RecordCollectionViewCell.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/17.
//

import UIKit

class RecordCollectionViewCell: UICollectionViewCell {
    
  static let identifier = "recordCell"
  
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var rateImageView: UIImageView!
  
}
