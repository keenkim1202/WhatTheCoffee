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
  
  // MARK: - UI
  @IBOutlet weak var cafeImageView: UIImageView!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var operationLabel: UILabel!
  @IBOutlet weak var mapView: MKMapView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  // MARK: - Action
  @IBAction func onClose(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
}
