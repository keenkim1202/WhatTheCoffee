//
//  SceneDelegate.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/17.
//

import UIKit
import Realm
import RealmSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  var environment: Environment? = nil
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = (scene as? UIWindowScene) else { return }
    guard let window = scene.windows.first else { return }
    guard let tabBar = window.rootViewController as? UITabBarController else { return }
    guard let viewControllers = tabBar.viewControllers else { return }
    
    let realm = try! Realm()
    environment = AppEnvironment(coffeeRepository: CoffeeRepository(realm: realm), cafeRepsitory: CafeRepository(realm: realm))
    
    for vc in viewControllers {
      switch vc.children.first {
      case let vc as RecommendViewController:
        vc.environment = environment
        
      case let vc as RecordsViewController:
        vc.environment = environment
        
      default:
        break
      }
    }
    
    for family in UIFont.familyNames {
         print(family)
         
         for names in UIFont.fontNames(forFamilyName: family){
             print("== \(names)")
         }
         
     }
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
  }
  
}

