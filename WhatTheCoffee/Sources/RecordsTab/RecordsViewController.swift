//
//  RecordsViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit
import FirebaseAnalytics

// TODO: searchBar 글씨체 수정 가능한지 찾아보기
// TODO: searchBar 화면 초기에는 안보이고, 아래로 스크롤 시에 나타나도록 하는 것 찾아보기

class RecordsViewController: BaseViewController {
  
  // MARK: - ModeType
  enum ModeType {
    case view
    case edit
  }
  
  // MARK: - Metric
  struct Metric {
    static var spacing: CGFloat = 10
    static var cellForItemCount: CGFloat = 2
  }
  
  // MARK: - Properties
  let cellInsets = UIEdgeInsets(top: Metric.spacing, left: Metric.spacing, bottom: Metric.spacing, right: Metric.spacing)
  var dictionarySelectedIndexPath: [IndexPath: Bool] = [:]
  var environment: Environment? = nil
  
  var cafeList: [Cafe] = [] {
    didSet { recordCollectionView.reloadData() }
  }
  
  var modeType: ModeType = .view {
    didSet {
      switch modeType {
      case .view:
        for (key, value) in dictionarySelectedIndexPath {
          if value {
            recordCollectionView.deselectItem(at: key, animated: true)
          }
        }
        dictionarySelectedIndexPath.removeAll()
        
        recordCollectionView.allowsMultipleSelection = false
        deleteBarButtonItem.isEnabled = false
        addBarButtonItem.isEnabled = true
        editBarButtonItem.title = "편집"
      case .edit:
        recordCollectionView.allowsMultipleSelection = true
        deleteBarButtonItem.isEnabled = true
        addBarButtonItem.isEnabled = false
        editBarButtonItem.title = "취소"
      }
    }
  }
  
  // MARK: - UI
  @IBOutlet weak var recordCollectionView: UICollectionView!
  @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var deleteBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var emptyView: UIView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureSearchController()
    configure()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Analytics.logEvent("TAB_records", parameters: nil)
    fetchData()
    checkIsEmpty()
  }
  
  func fetchData() {
    guard let env = environment else { return }
    cafeList = env.cafeRepository.fetch()
  }
  
  func checkIsEmpty() {
    if cafeList.isEmpty {
      emptyView.isHidden = false
    } else {
      emptyView.isHidden = true
    }
  }
  
  // MARK: - Configure
  func configure() {
    let layout = UICollectionViewFlowLayout()
    recordCollectionView.collectionViewLayout = layout
    
    recordCollectionView.delegate = self
    recordCollectionView.dataSource = self
    recordCollectionView.register(UINib(nibName: "RecordCell", bundle: nil), forCellWithReuseIdentifier: RecordCollectionViewCell.identifier)
    
    deleteBarButtonItem.tintColor = .red
  }
  
  func configureSearchController() {
    let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "searchVC") as! RecordSearchViewController
    let searchController = UISearchController(searchResultsController: searchVC)
    
    searchController.searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
    searchController.searchBar.delegate = self
    searchController.searchBar.placeholder = "카페 이름으로 검색해보세요!"
    
    self.definesPresentationContext = true
    self.navigationItem.searchController = searchController
  }
  
  func changeDeleteButtonState() {
    modeType = modeType == .view ? .edit : .view
  }
  
  // TODO: 셀 삭제 시 이미지들도 지우도록 하기
  @IBAction func onDelete(_ sender: UIBarButtonItem) {
    var deleteNeededIndexPaths: [IndexPath] = []
    for (key, value) in dictionarySelectedIndexPath {
      if value {
        deleteNeededIndexPaths.append(key)
      }
    }
    
    if deleteNeededIndexPaths.count > 0 {
      deleteAlert("\(deleteNeededIndexPaths.count)개의 기록을 삭제하시겠습니까?") {
        for i in deleteNeededIndexPaths.sorted(by: { $0.item > $1.item }) {
          let item = self.cafeList[i.item]
          guard let env = self.environment else { return }
          
          self.deleteImageFromDucumentDirectory(type: .cafe, imageName: "cafe_\(item._id).jpg")
          env.cafeRepository.remove(item: item)
        }
        
        self.fetchData()
        self.checkIsEmpty()
        self.dictionarySelectedIndexPath.removeAll()
      }
    } else {
      showErrorAlert("삭제할 기록을 선택해주세요.")
    }
  }
  
  // MARK: - Actions
  @IBAction func onEdit(_ sender: UIBarButtonItem) {
    changeDeleteButtonState()
  }
  
  @IBAction func onAdd(_ sender: UIBarButtonItem) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "addRecordVC") as! AddRecordViewController
    vc.environment = environment
    
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    self.present(nav, animated: true, completion: nil)
  }
}

// MARK: Extension
// MARK: - UICollectionViewDelegate
extension RecordsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return cellInsets
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch modeType {
    case .view:
      recordCollectionView.deselectItem(at: indexPath, animated: true)
      
      guard let vc = storyboard?.instantiateViewController(withIdentifier: "addRecordVC") as? AddRecordViewController else { return }
      guard let env = environment else { return }
      
      let cafe = cafeList[indexPath.item]
      vc.environment = env
      vc.cafe = cafe
      
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = .fullScreen
      self.present(nav, animated: true, completion: nil)
      
    case .edit:
      dictionarySelectedIndexPath[indexPath] = true
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    if modeType == .edit {
      dictionarySelectedIndexPath[indexPath] = false
    }
  }
}

// MARK: - UICollectionViewDataSource
extension RecordsViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return cafeList.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = recordCollectionView.dequeueReusableCell(withReuseIdentifier: RecordCollectionViewCell.identifier, for: indexPath) as? RecordCollectionViewCell else { return UICollectionViewCell() }
    let item = cafeList[indexPath.item]
    
    cell.backgroundImageView.image = loadImageFromDocumentDirectory(type: .cafe, imageName: "cafe_\(item._id).jpg") ?? UIImage.defaultCafeImage
    cell.cellConfigure(with: item)
    
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RecordsViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let screenSize = UIScreen.main.bounds.size
    let spacing = Metric.spacing * (Metric.cellForItemCount - 1 + 2)
    let width = (screenSize.width - spacing) / Metric.cellForItemCount
    
    return CGSize(width: width, height: width)
  }
}

// MARK: - UISearchBarDelegate -
extension RecordsViewController: UISearchBarDelegate {
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    self.becomeFirstResponder()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    self.recordCollectionView.reloadData()
  }
}

// MARK: - UISearchResultsUpdating -
extension RecordsViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchVC = searchController.searchResultsController as! RecordSearchViewController
    guard let query = searchController.searchBar.text else { return }
    
    searchVC.queryText = query
  }
}
