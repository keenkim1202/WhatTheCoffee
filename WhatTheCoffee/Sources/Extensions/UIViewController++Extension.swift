//
//  UIViewController++Extension.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/22.
//

import Foundation
import UIKit


extension UIViewController {
  // MARK: - Document Date Manage
  func saveImageToDocumentDirectory(imageName: String, image: UIImage) {
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    let imageURL = documentDirectory.appendingPathComponent(imageName)
  
    guard let data = image.pngData() else { return }
    
    if FileManager.default.fileExists(atPath: imageURL.path) {
      do {
        try FileManager.default.removeItem(at: imageURL)
        print("SUCCESS - image deleted.")
      } catch {
        print("FAILED - fail to delete image.")
      }
    }
  
    do {
      try data.write(to: imageURL)
      print("SUCCESS - image saved.")
    } catch {
      print("FAILED - fail to save image.")
    }
  }
  
  func loadImageFromDocumentDirectory(imageName: String) -> UIImage? {
    let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
    
    if let directoryPath = path.first {
      let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(imageName)
      return UIImage(contentsOfFile: imageURL.path)
    }
    return nil
  }
  
  // MARK:  Configuring Alert
  func showAlert(_ message: String) {
    UIAlertController
      .show(self, contentType: .error, message: message)
  }
}
