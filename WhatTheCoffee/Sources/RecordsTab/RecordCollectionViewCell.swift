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
  @IBOutlet weak var checkImageView: UIImageView! // 편집 시 선택 채크 이미지
  @IBOutlet weak var highlightView: UIView! // 셀이 체크 되었음을 보여주기 위해 색상변경을 줄 뷰
  
  override var isHighlighted: Bool {
    didSet {
      highlightView.isHidden = !isHighlighted
    }
  }
  
  override var isSelected: Bool {
    didSet {
      highlightView.isHidden = !isSelected
      checkImageView.isHidden = !isSelected
    }
  }
  
  func cellConfigure(with item: Cafe) {
    self.layer.cornerRadius = CGFloat(8)
    self.clipsToBounds = true
    
    nameLabel.text = item.name
    rateImageView.image = UIImage(named: "star\(item.rate)")!
    dateLabel.text = DateFormatter.visitDateFormat.string(from: item.visitDate)
  }
  
}
