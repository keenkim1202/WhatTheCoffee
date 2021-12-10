//
//  NearCafeViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit
import CoreLocation
import FirebaseAnalytics

class NearCafeViewController: UIViewController {
  
  // MARK: - Properties
  let perPage: Int = 15
  var environment: Environment? = nil
  var locationManger = CLLocationManager()
  var queryText: String?
  var page: Int = 1
  var totalCount: Int = 0
  var isEnd: Bool = false
  var nearCafeList: [NearCafe] = [] {
    didSet {
      if !nearCafeList.isEmpty {
        emptyLabel.textColor = .clear
      } else {
        emptyLabel.textColor = .systemYellow
      }
//      tableView.reloadData()
    }
  }
  
  var userCoordinate: CLLocationCoordinate2D? {
     didSet {
       fetchData(query: "카페")
     }
  }
  
  // MARK: - UI
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var emptyLabel: UILabel!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    print(#function)
    configure()
    configureLocationManager()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Analytics.logEvent("TAB_nearCafe", parameters: nil)
  }
  
  // MARK: - Configure
  func configure() {
    adjustNavigationBarFont()
    
    let searchController = UISearchController()

    searchController.searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
    searchController.delegate = self
    searchController.searchBar.delegate = self
    
    self.definesPresentationContext = true
    self.navigationItem.searchController = searchController
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.prefetchDataSource = self
  }
  
  func configureLocationManager() {
    locationManger.delegate = self
    locationManger.desiredAccuracy = kCLLocationAccuracyBest
    locationManger.requestWhenInUseAuthorization()
    
    if CLLocationManager.locationServicesEnabled() {
        print("위치 서비스 On 상태")
     locationManger.startUpdatingLocation()
      
      if let location = locationManger.location {
        userCoordinate = location.coordinate
      }
    } else {
        print("위치 서비스 Off 상태")
    }
  }
  
  func fetchData(query: String, page: Int = 1) {
    print(#function)
    
    if let coor = userCoordinate {
      let latitude = coor.latitude
      let longitude = coor.longitude
      
      DispatchQueue.global().async {
        APIService.shared.fetchCafeInfo(pos: (latitude,longitude), query: query, page: page) { code, json in
          let meta = json["meta"]
          self.totalCount = meta["total_count"].intValue
          self.isEnd = meta["isEnd"].boolValue
          
          let storeList = json["documents"]
          _ = storeList.map {
            let addressName = $0.1["road_address_name"].stringValue
            let placeUrl = $0.1["place_url"].stringValue
            let placeName = $0.1["place_name"].stringValue
            let x = $0.1["x"].doubleValue
            let y = $0.1["y"].doubleValue
            
            let cafe = NearCafe(name: placeName, address: addressName, latitude: y, longitude: x, placeUrl: placeUrl)
            self.nearCafeList.append(cafe)
          }

          DispatchQueue.main.async {
            self.tableView.reloadData()
          }
        }
      }
    } else {
      print("현재 위치 정보가 없음. 근처 카페 목록 검색 불가.")
    }
    
    print("cafeCount: ", nearCafeList.count)
    print("page - ", page)
    print("isEnd: \(isEnd), total: \(totalCount)")
  }

  // MARK: - Action
  @IBAction func onRedo(_ sender: UIBarButtonItem) {
    fetchData(query: "카페")
  }
  
  @IBAction func onCafeLocation(_ sender: UIBarButtonItem) {
    if !nearCafeList.isEmpty {
      guard let vc = storyboard?.instantiateViewController(withIdentifier: "cafeLocationVC") as? CafeLocationViewController else { return }
      vc.nearCafeLists = nearCafeList
      vc.myLocation = userCoordinate
  
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = .fullScreen
      self.present(nav, animated: true, completion: nil)
    } else {
      showAlert("지도에 표시할 카페가 없어요😅\n다시 검색해주세요.")
    }
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

// MARK: - UITableViewDataSourcePrefetching
extension NearCafeViewController: UITableViewDataSourcePrefetching {
  // TODO: 수정...
  func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    
    // totalCount: 검색한 카페 갯수
    // isEnd: 마지막 페이지 인지 체크
    // page: 현재 페이지
    // pageable_count: 최대 페이지수
    
    // page가 pagable_count가 될때까지 증가시키면서 prefetch하기. 만약 isEnd가 true 이면 prefetch 하지 않음.
    
    // prefetch 타이밍은 테이블뷰의 indexPath.row가 nearCafe의 갯수 -1 과 같을때!
    for indexPath in indexPaths {
        
      if (nearCafeList.count - 1 == indexPath.row) {
        
        if isEnd == false {
          page += 1
          
          if let text = queryText {
            self.fetchData(query: text, page: page)
            print("fetched - \(page) of \(totalCount)")
          } else {
            self.fetchData(query: "카페", page: page)
          }
        } else {
          print("마지막 페이지: \(page)")
        }

        print("prefetched IndexPath: \(indexPath)")
      }
  }
  }
  
  func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    print("최소 - \(indexPaths)")
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

// MARK: - CLLocationManagerDelegate -
extension NearCafeViewController: CLLocationManagerDelegate {
  // 위치 정보 계속 업데이트 -> 위도 경도 받아옴
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
  }
  
  // 위도 경도 받아오기 에러
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}

// MARK: - UISearchBarDelegate -
extension NearCafeViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    guard let query = searchBar.text else { return }
    nearCafeList.removeAll()
    totalCount = 0
    page = 1
    fetchData(query: query)
    queryText = query
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    self.becomeFirstResponder()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    self.tableView.reloadData()
  }
}

// MARK: - UISearchControllerDelegate -
extension NearCafeViewController: UISearchControllerDelegate {
  
}
