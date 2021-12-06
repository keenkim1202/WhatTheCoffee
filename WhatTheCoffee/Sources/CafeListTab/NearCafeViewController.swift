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
  var nearCafeList: [NearCafe] = [] {
    didSet {
      if !nearCafeList.isEmpty {
        emptyLabel.textColor = .clear
      } else {
        emptyLabel.textColor = .systemYellow
      }
      tableView.reloadData()
    }
  }
  
  // MARK: - UI
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var emptyLabel: UILabel!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    fetchData()
  }
  
  // MARK: - Configure
  func configure() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  func fetchData() {
    nearCafeList = []
    APIService.shared.fetchCafeInfo(pos: (37.654893784621144,127.06157902459952), query: "스타벅스") { code, json in
      let storeList = json["documents"]
      print("JSON - ", json)
      _ = storeList.map {
        let addressName = $0.1["road_address_name"].stringValue
        let placeUrl = $0.1["pace_url"].stringValue
        let placeName = $0.1["place_name"].stringValue
        let x = $0.1["x"].doubleValue
        let y = $0.1["y"].doubleValue
        
        let cafe = NearCafe(name: placeName, address: addressName, point: (x, y), placeUrl: placeUrl)
        self.nearCafeList.append(cafe)
      }
    }
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
    vc.nearCafe = nearCafeList[indexPath.row]
    
    let nav = UINavigationController(rootViewController: vc)
    nav.title = nearCafeList[indexPath.row].name
    nav.modalPresentationStyle = .fullScreen
    self.present(nav, animated: true, completion: nil)
  }
}

// MARK: - UITableViewDataSource
extension NearCafeViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return nearCafeList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: NearCafeTableViewCell.identifier) as? NearCafeTableViewCell else { return UITableViewCell() }
    let row = nearCafeList[indexPath.row]
    cell.cellConfigure(row: row)
    cell.cafeImageView.image = UIImage.NearCafePlaceholder
    
    cell.selectionStyle = .none
    return cell
  }
  
  
}
