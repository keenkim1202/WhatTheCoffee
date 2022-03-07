//
//  DetailNearCafeViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit
import MapKit
import WebKit
import NMapsMap
import CoreLocation

class DetailNearCafeViewController: BaseViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  var nearCafe: NearCafe?
  
  // MARK: - UI
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var detailInfoButton: UIButton!
  @IBOutlet weak var naverMapView: NMFNaverMapView!
  @IBOutlet weak var backgroundView: UIView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    configure()
  }
  
  // MARK: - Configure
  func configure() {
    detailInfoButton.layer.cornerRadius = CGFloat(8)
    backgroundView.layer.cornerRadius = CGFloat(8)
    naverMapView.layer.cornerRadius = CGFloat(8)
    
    if let cafe = nearCafe {
      self.navigationItem.title = cafe.name
      addressLabel.text = cafe.address
      
      let lat = cafe.latitude
      let long = cafe.longitude
      
      naverMapView.showZoomControls = true
      moveCamera(lat: lat, long: long)
      pinMaker(lat: lat, long: long, caption: cafe.name)
    }
  }
  
  // MARK: 지도 시점 이동
  func moveCamera(lat: Double, long: Double) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: long))
    cameraUpdate.reason = 3
    cameraUpdate.animation = .none
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
    
    marker.iconImage = NMFOverlayImage(name: "coffee_marker_shadow")
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
  
  @IBAction func onDetailInfo(_ sender: UIButton) {
    guard let nearCafe = nearCafe else { return }
    guard let detailSettingVC = self.storyboard?.instantiateViewController(withIdentifier: "detailSettingVC") as? SettingDetailViewController else { return }
    
    detailSettingVC.url = nearCafe.placeUrl
    detailSettingVC.title = nearCafe.name
    
    let nav = UINavigationController(rootViewController: detailSettingVC)
    nav.modalPresentationStyle = .fullScreen
    self.present(nav, animated: true, completion: nil)
  }
  
}
