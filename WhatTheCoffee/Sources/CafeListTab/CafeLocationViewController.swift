//
//  CafeLocationViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit
import MapKit

class CafeLocationViewController: UIViewController {
  
  // MARK: - UI
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
