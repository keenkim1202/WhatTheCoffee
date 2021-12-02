//
//  NearCafeViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit

class NearCafeViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  let imageList: [String] = ["할리스", "투썸플레이스", "스타벅스", "탐앤탐스", "커피빈", "이디야"]
  let dummyList: [NearCafe] = [
    NearCafe(name: "할리스", address: "서울시 00구 00동", operationTime: "09:00 - 22:00"),
    NearCafe(name: "투썸플레이스", address: "서울시 11구 11동", operationTime: "08:00 - 21:00"),
    NearCafe(name: "스타벅스", address: "서울시 22구 22동", operationTime: "08:30 - 21:30"),
    NearCafe(name: "탐앤탐스", address: "서울시 33구 33동", operationTime: "07:00 - 22:30"),
    NearCafe(name: "커피빈", address: "서울시 44구 44동", operationTime: "07:30 - 21:00"),
    NearCafe(name: "이디야", address: "서울시 55구 55동", operationTime: "10:00 - 23:00")
  ]
  
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
    guard let vc = storyboard?.instantiateViewController(withIdentifier: "cafeLocationVC") as? CafeLocationViewController else { return }
    let nav = UINavigationController(rootViewController: vc)
    
    nav.modalPresentationStyle = .fullScreen
    self.present(nav, animated: true, completion: nil)
  }
  
}

// MARK: - Extension
// MARK: - UITableViewDelegate
extension NearCafeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let vc = storyboard?.instantiateViewController(withIdentifier: "detailNearCafeVC") as? DetailNearCafeViewController else { return }
    guard let environment = environment else { return }
    vc.environment = environment
    vc.nearCafe = dummyList[indexPath.row]
    
    let nav = UINavigationController(rootViewController: vc)
    nav.title = dummyList[indexPath.row].name
    nav.modalPresentationStyle = .fullScreen
    self.present(nav, animated: true, completion: nil)
  }
}

// MARK: - UITableViewDataSource
extension NearCafeViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dummyList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: NearCafeTableViewCell.identifier) as? NearCafeTableViewCell else { return UITableViewCell() }
    let row = dummyList[indexPath.row]
    cell.cellConfigure(row: row)
    cell.cafeImageView.image = UIImage(named: imageList[indexPath.row]) ?? UIImage.NearCafePlaceholder
    
    cell.selectionStyle = .none
    return cell
  }
  
  
}
