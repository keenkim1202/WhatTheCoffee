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
  
    enum DirectoryType: String {
      case coffee = "coffeeImages"
      case cafe = "cafeImages"
    }
  
  // MARK: - Save Document
  func saveImageToDocumentDirectory(type: DirectoryType, imageName: String, image: UIImage) {
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    
    let filePath = documentDirectory.appendingPathComponent(type.rawValue)
    if !FileManager.default.fileExists(atPath: filePath.path) {
      do {
        try FileManager.default.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print(error.localizedDescription)
      }
    }
    
    let imageURL = filePath.appendingPathComponent(imageName)
    guard let data = image.jpegData(compressionQuality: 0.5) else { return }
    
    if FileManager.default.fileExists(atPath: filePath.path) {
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
  func loadImageFromDocumentDirectory(type: DirectoryType, imageName: String) -> UIImage? {
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
    let filePath = documentDirectory.appendingPathComponent(type.rawValue)
    
    if !FileManager.default.fileExists(atPath: filePath.path) {
      do {
        try FileManager.default.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print(error.localizedDescription)
      }
    }
    
    let imageURL = filePath.appendingPathComponent(imageName)
    return UIImage(contentsOfFile: imageURL.path)
  }
  
  // MARK: - Remove Document
  func deleteImageFromDucumentDirectory(type: DirectoryType, imageName: String) {
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    
    let filePath = documentDirectory.appendingPathComponent(type.rawValue)
    
    if !FileManager.default.fileExists(atPath: filePath.path) {
      do {
        try FileManager.default.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print(error.localizedDescription)
      }
    }
    
    let imageURL = filePath.appendingPathComponent(imageName)
    
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
