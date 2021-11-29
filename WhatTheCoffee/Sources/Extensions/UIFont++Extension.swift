//
//  UIFont++Extension.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/29.
//

import UIKit

extension UIFont {
  class func KyoboHandWriting(type: KyoboHandWritingType, size: CGFloat) -> UIFont! {
    guard let font = UIFont(name: type.name, size: size) else {
      return nil
    }
    
    return font
  }
  
  public enum KyoboHandWritingType {
    case regular
    
    var name: String {
      switch self {
      case .regular:
        return "Kyobo Handwriting 2019"
        
      }
    }
  }
}
