//
//  NearCafeViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit

class NearCafeViewController: UIViewController {
  
  // MARK: - Properties
  
  // MARK: - UI
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
  
  // MARK: - Configure
  func configure() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  // MARK: - Action
  @IBAction func onCafeLocation(_ sender: UIBarButtonItem) {
    
  }
  
}

// MARK: - Extension
// MARK: - UITableViewDelegate
extension NearCafeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90
  }
}

// MARK: - UITableViewDataSource
extension NearCafeViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: NearCafeTableViewCell.identifier) as? NearCafeTableViewCell else { return UITableViewCell() }
    return cell
  }
  
  
}
