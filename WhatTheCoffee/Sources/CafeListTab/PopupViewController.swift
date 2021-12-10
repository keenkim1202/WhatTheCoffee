//
//  PopupViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/12/10.
//

import UIKit

class PopupViewController: UIViewController {
  
  // MARK: - Properties
  var cafe: NearCafe?
  
  // MARK: - UI
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var detailButton: UIButton!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
    
    if let cafe = cafe {
      nameLabel.text = cafe.name
      addressLabel.text = cafe.address
    }
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    if let touch = touches.first , touch.view == self.view {
      self.dismiss(animated: false, completion: nil)
    }
  }
  
  // MARK: - Configure
  func configure() {
    backgroundView.layer.cornerRadius = CGFloat(8)
    closeButton.layer.cornerRadius = CGFloat(8)
    detailButton.layer.cornerRadius = CGFloat(15)
    
    
  }
  
  // MARK: - Action
  @IBAction func onClose(_ sender: UIButton) {
    self.dismiss(animated: false, completion: nil)
  }
  
  @IBAction func onDetailInfo(_ sender: UIButton) {
    guard let nearCafe = cafe else { return }
    guard let detailSettingVC = self.storyboard?.instantiateViewController(withIdentifier: "detailSettingVC") as? SettingDetailViewController else { return }
    
    detailSettingVC.url = nearCafe.placeUrl
    self.present(detailSettingVC, animated: true, completion: nil)
  }
  
}
