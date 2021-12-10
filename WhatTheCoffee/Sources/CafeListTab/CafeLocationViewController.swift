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
  var locationManger = CLLocationManager()
  var myLocation: CLLocationCoordinate2D?
  
  // MARK: - UI
  @IBOutlet weak var naverMapView: NMFNaverMapView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureLocationManager()
    
    if !nearCafeLists.isEmpty {
      moveCamera(lat: myLocation!.latitude, long: myLocation!.longitude)
      
      for cafe in nearCafeLists {
        let latitude = cafe.latitude
        let longitude = cafe.longitude
        let name = cafe.name
        pinMaker(lat: latitude, long: longitude, caption: name)
      }
    } else {
      print("cafeList is empty.")
    }
  }
  
  // MARK: - Configure
  func configureLocationManager() {
    locationManger.delegate = self
    locationManger.desiredAccuracy = kCLLocationAccuracyBest
    locationManger.requestWhenInUseAuthorization()
    
    naverMapView.showLocationButton = true
    
    if CLLocationManager.locationServicesEnabled() {
        print("위치 서비스 On 상태")
     locationManger.startUpdatingLocation()
      
      if let location = locationManger.location {
        myLocation = location.coordinate
      }
    } else {
        print("위치 서비스 Off 상태")
    }
  }
  
  // MARK: 지도 시점 이동
  func moveCamera(lat: Double, long: Double) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: long))
    cameraUpdate.reason = 3
    cameraUpdate.animation = .fly
    cameraUpdate.animationDuration = 2
    
    naverMapView.mapView.moveCamera(cameraUpdate, completion: { (isCancelled) in
      if isCancelled {
        print("카메라 이동 취소")
      } else {
        print("카메라 이동 성공")
      }
    })
  }
  
  // MARK: 지도에 pin 찍기
  func pinMaker(lat: Double, long: Double, caption: String) {
    let marker = NMFMarker(position: NMGLatLng(lat: lat, lng: long))
    marker.touchHandler = { (overlay) in
      print("마커 클릭됨")
      return true
    }
    
    marker.iconImage = NMFOverlayImage(name: "coffee_marker_shadow")
//    marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
//    marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
    marker.width = 30
    marker.height = 33
    marker.anchor = CGPoint(x: 1, y: 1)
    marker.captionText = caption
    marker.mapView = naverMapView.mapView
  }
  
  // MARK: - Action
  @IBAction func onClose(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
}

// MARK: - CLLocationManagerDelegate -
extension CafeLocationViewController: CLLocationManagerDelegate {
  // 위치 정보 계속 업데이트 -> 위도 경도 받아옴
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("didUpdateLocations")
    if let location = locations.first {
      myLocation = location.coordinate
      print("위도: \(location.coordinate.latitude)")
      print("경도: \(location.coordinate.longitude)")
    }
  }
  
  // 위도 경도 받아오기 에러
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
