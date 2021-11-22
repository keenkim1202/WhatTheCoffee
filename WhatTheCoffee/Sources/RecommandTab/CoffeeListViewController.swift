//
//  CoffeeListViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit

class CoffeeListViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  
  // MARK: - UI
  @IBOutlet weak var tableView: UITableView!
  let dummyList: [String] = ["아메리카노", "에스프레소", "카페 라떼", "바닐라 라떼", "헤이즐넛 라떼", "카라멜 메끼에또"]
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  // MARK: - Actions
  @IBAction func onClose(_ sender: UIBarButtonItem) {
    print(#function)
    self.dismiss(animated: true, completion: nil)
  }
  
}

// MARK: Extension
// MARK: - UITableViewDelegate
extension CoffeeListViewController: UITableViewDelegate {
  
}

// MARK: - UITableViewDataSource
extension CoffeeListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dummyList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: CoffeeListTableViewCell.identifier) as? CoffeeListTableViewCell else { return UITableViewCell() }
    cell.nameLabel.text = dummyList[indexPath.row]
    return cell
  }
  
  
}
