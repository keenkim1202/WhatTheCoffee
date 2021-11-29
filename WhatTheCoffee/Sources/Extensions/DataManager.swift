//
//  DataManager.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/25.
//

import UIKit

// TODO: 이미지 변경 시, 이전 이미지 삭제하도록 하기. -> delete 함수 수정하기. (뭔가 이상함)
// MARK: - Document Date Manage
extension UIViewController {
  
//  enum DirectoryType: String {
//    case coffee = "coffeeImages"
//    case cafe = "cafeImages"
//  }
  
  // MARK: - Save Document
  func saveImageToDocumentDirectory(imageName: String, image: UIImage) {
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    let imageURL = documentDirectory.appendingPathComponent(imageName)
  
    guard let data = image.jpegData(compressionQuality: 0.5) else { return }
    
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
  
  // MARK: - Load Document
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
  
  // MARK: - Remove Document
  func deleteImageFromDucumnetDirectory(imageName: String) {
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    let imageURL = documentDirectory.appendingPathComponent(imageName)

    if FileManager.default.fileExists(atPath: imageURL.path) {
      do {
        try FileManager.default.removeItem(at: imageURL)
        print("REMOVE SUCCESS")
      } catch {
        print("REMOVE FAILED")
      }
    }
  }
}
