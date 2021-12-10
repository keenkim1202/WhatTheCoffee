//
//  CafeLocationViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit
import MapKit
import NMapsMap

class CafeLocationViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  var nearCafeLists: [NearCafe] = []
  
  // MARK: - UI
  @IBOutlet weak var mapView: NMFMapView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if !nearCafeLists.isEmpty {
      print(nearCafeLists.first!.latitude, nearCafeLists.first!.longitude)
      moveCamera(lat: nearCafeLists.first!.latitude, long: nearCafeLists.first!.longitude)
      
      for cafe in nearCafeLists {
        let latitude = cafe.latitude
        let longitude = cafe.longitude
        pinMaker(lat: latitude, long: longitude)
      }
    } else {
      print("cafeList is empty.")
    }
//    moveCamera(lat: 37.5666102, long: 126.9783881)
//    pinMaker(lat: 37.5670135, long: 126.9783740)
  }
  
  // MARK: 지도 시점 이동
  func moveCamera(lat: Double, long: Double) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: long))
    cameraUpdate.reason = 3
    cameraUpdate.animation = .fly
    cameraUpdate.animationDuration = 2
    mapView.moveCamera(cameraUpdate, completion: { (isCancelled) in
      if isCancelled {
        print("카메라 이동 취소")
      } else {
        print("카메라 이동 성공")
      }
    })
  }
  
  // MARK: 지도에 pin 찍기
  func pinMaker(lat: Double, long: Double) {
    let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: long))
    marker.touchHandler = { (overlay) in
      print("마커 클릭됨")
      return true
    }
    marker.mapView = mapView
  }
  
  // MARK: - Action
  @IBAction func onClose(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
}
