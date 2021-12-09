//
//  DetailNearCafeViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit
import MapKit
import WebKit

class DetailNearCafeViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  var nearCafe: NearCafe?
  let imageList: [String] = ["할리스", "투썸플레이스", "스타벅스", "탐앤탐스", "커피빈", "이디야"]
  
  // MARK: - UI
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var detailInfoButton: UIButton!
  @IBOutlet weak var mapView: MKMapView!
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
    mapView.layer.cornerRadius = CGFloat(8)
    
    if let cafe = nearCafe {
      self.navigationItem.title = cafe.name
      addressLabel.text = cafe.address
    }
  }
  
  // MARK: - Action
  @IBAction func onClose(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func onDetailInfo(_ sender: UIButton) {
    print("clicked")
    guard let nearCafe = nearCafe else { return }
    print("nearCafe OK.")
    guard let detailSettingVC = self.storyboard?.instantiateViewController(withIdentifier: "detailSettingVC") as? SettingDetailViewController else { return }
    print("vc OK.")
    detailSettingVC.url = nearCafe.placeUrl
    print(nearCafe.placeUrl)
    self.present(detailSettingVC, animated: true, completion: nil)
  }
  
}
