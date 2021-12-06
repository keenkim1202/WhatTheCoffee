//
//  NearCafeViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit
import CoreLocation

class NearCafeViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  var locationManger = CLLocationManager()
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
  var longitude: Double?
  var latitude: Double?
  
  // MARK: - UI
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var emptyLabel: UILabel!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    print(#function)
    configure()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print(#function)
    fetchData()
  }
  
  // MARK: - Configure
  func configure() {
    tableView.delegate = self
    tableView.dataSource = self
    
    locationManger.delegate = self
    locationManger.desiredAccuracy = kCLLocationAccuracyBest
    locationManger.requestWhenInUseAuthorization()
    
    // 아이폰 설정에서의 위치 서비스가 켜진 상태라면
    if CLLocationManager.locationServicesEnabled() {
        print("위치 서비스 On 상태")
     locationManger.startUpdatingLocation() //위치 정보 받아오기 시작
        print(locationManger.location?.coordinate)
    } else {
        print("위치 서비스 Off 상태")
    }
  }
  
  func fetchData() {
    nearCafeList = []
    
    if let latitude = latitude, let longitude = longitude {
      APIService.shared.fetchCafeInfo(pos: (latitude,longitude), query: "스타벅스") { code, json in
        let storeList = json["documents"]
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
    } else {
      print("현재 위치 정보가 없음. 근처 카페 목록 검색 불가.")
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

// MARK: - CLLocationManagerDelegate
extension NearCafeViewController: CLLocationManagerDelegate {
  // 위치 정보 계속 업데이트 -> 위도 경도 받아옴
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("didUpdateLocations")
    if let location = locations.first {
      latitude = location.coordinate.latitude
      longitude = location.coordinate.longitude
      print("위도: \(location.coordinate.latitude)")
      print("경도: \(location.coordinate.longitude)")
    }
  }
  
  // 위도 경도 받아오기 에러
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
