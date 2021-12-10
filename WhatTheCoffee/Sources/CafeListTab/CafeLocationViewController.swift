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
  
  // MARK: - UI
  @IBOutlet weak var mapView: NMFMapView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
  
  // MARK: - Action
  @IBAction func onClose(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
}
