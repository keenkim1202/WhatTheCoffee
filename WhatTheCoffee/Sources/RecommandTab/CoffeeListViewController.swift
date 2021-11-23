//
//  CoffeeListViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit
import Network

class CoffeeListViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  var coffeeList: [Coffee] = []
  
  // MARK: - UI
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    print("coffeeList VC - vdl")
    
    tableView.delegate = self
    tableView.dataSource = self
    
    configure()
  }
  
  func configure() {
//    guard let env = environment else { return }
//    coffeeList = env.coffeeRepository.fetch()
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
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let vc = storyboard?.instantiateViewController(withIdentifier: "addCoffeeVC") as? AddCoffeeViewController else { return }
    let coffee = coffeeList[indexPath.row]
    
    vc.environment = environment
    vc.coffee = coffee
  
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: - UITableViewDataSource
extension CoffeeListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return coffeeList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: CoffeeListTableViewCell.identifier) as? CoffeeListTableViewCell else { return UITableViewCell() }
    let row = coffeeList[indexPath.row]
    cell.nameLabel.text = row.name
    cell.coffeeImageView.image = loadImageFromDocumentDirectory(imageName: "\(row._id).jpg") ?? UIImage(named: "random")
    
    return cell
  }
  
  
}
