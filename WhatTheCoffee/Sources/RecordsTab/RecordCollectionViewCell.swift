//
//  RecordCollectionViewCell.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/17.
//

import UIKit

class RecordCollectionViewCell: UICollectionViewCell {
    
  static let identifier = "recordCell"
  
  @IBOutlet weak var cellView: UIView!
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var rateImageView: UIImageView!
  
  func cellConfigure(with item: Cafe) {
    self.layer.cornerRadius = CGFloat(8)
    self.clipsToBounds = true
    
    nameLabel.text = item.name
    backgroundImageView.image = UIImage(named: "\(item._id).jpg") ?? UIImage(named: "random")
    rateImageView.image = UIImage(named: "star\(item.rate)")!
    dateLabel.text = DateFormatter.visitDateFormat.string(from: item.visitDate)
  }
  
}
