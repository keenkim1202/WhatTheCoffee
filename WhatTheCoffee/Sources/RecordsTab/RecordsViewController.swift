//
//  RecordsViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit

class RecordsViewController: UIViewController {
  
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
  
  var environment: Environment? = nil
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
  var cafeList: [Cafe] = [] { didSet { recordCollectionView.reloadData() } }
  var dictionarySelectedIndexPath: [IndexPath: Bool] = [:]

  
  // MARK: - UI
  @IBOutlet weak var recordCollectionView: UICollectionView!
  @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var deleteBarButtonItem: UIBarButtonItem!
  
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    fetchData()
  }
  
  func fetchData() {
    guard let env = environment else { return }
    cafeList = env.cafeRepository.fetch()
  }
  
  // MARK: - Configure
  func configure() {
    let layout = UICollectionViewFlowLayout()
    recordCollectionView.collectionViewLayout = layout
    
    recordCollectionView.delegate = self
    recordCollectionView.dataSource = self
    recordCollectionView.register(UINib(nibName: "RecordCell", bundle: nil), forCellWithReuseIdentifier: RecordCollectionViewCell.identifier
    )
    
    deleteBarButtonItem.tintColor = .orange
    editBarButtonItem.tintColor = .brown
  }
  
  func changeDeleteButtonState() {
    modeType = modeType == .view ? .edit : .view
  }
  
  @IBAction func onDelete(_ sender: UIBarButtonItem) {
    var deleteNeededIndexPaths: [IndexPath] = []
    for (key, value) in dictionarySelectedIndexPath {
      if value {
        deleteNeededIndexPaths.append(key)
      }
    }
    
    for i in deleteNeededIndexPaths.sorted(by: { $0.item > $1.item }) {
      let item = cafeList[i.item]
      environment?.cafeRepository.remove(item: item)
    }
    
    fetchData()
    dictionarySelectedIndexPath.removeAll()
  }
  
  // MARK: - Actions
  @IBAction func onEdit(_ sender: UIBarButtonItem) {
    changeDeleteButtonState()
  }
  
  @IBAction func onAdd(_ sender: UIBarButtonItem) {
    print(#function)
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
    
    cell.backgroundImageView.image = loadImageFromDocumentDirectory(imageName: "\(item._id).jpg") ?? UIImage(named: "cafeDefault3")
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
