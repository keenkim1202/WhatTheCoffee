//
//  DetailNearCafeViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit
import MapKit

class DetailNearCafeViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  var nearCafe: NearCafe?
  let imageList: [String] = ["할리스", "투썸플레이스", "스타벅스", "탐앤탐스", "커피빈", "이디야"]
  
  // MARK: - UI
  @IBOutlet weak var cafeImageView: UIImageView!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var operationLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var backgroundView: UIView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
  }
  
  // MARK: - Configure
  func configure() {
    cafeImageView.layer.cornerRadius = CGFloat(8)
    backgroundView.layer.cornerRadius = CGFloat(8)
    mapView.layer.cornerRadius = CGFloat(8)
    
    if let cafe = nearCafe {
      self.navigationItem.title = cafe.name
      cafeImageView.image = UIImage(named: cafe.name) ?? UIImage.NearCafePlaceholder
      addressLabel.text = cafe.address
      operationLabel.text = "상세보기"
    }
  }
  
  // MARK: - Action
  @IBAction func onClose(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
}
