//
//  RecordSearchViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2022/03/14.
//

import UIKit
import RealmSwift

class RecordSearchViewController: UIViewController {
  
  // MARK: - Metric
  struct Metric {
    static var spacing: CGFloat = 10
    static var cellForItemCount: CGFloat = 2
  }
  
  // MARK: - Properties
  var environment: Environment? = nil
  let cellInsets = UIEdgeInsets(top: Metric.spacing, left: Metric.spacing, bottom: Metric.spacing, right: Metric.spacing)
  var queryText: String = "" {
    didSet {
      searchData()
      }
  }

  var results: [Cafe] = [] {
    didSet {
      searchCollectionView.reloadData()
    }
  }
  
  // MARK: - UI
  @IBOutlet weak var searchCollectionView: UICollectionView!
  @IBOutlet weak var emptyView: UIView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configure()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    searchData()
  }
  
  func configure() {
    let layout = UICollectionViewFlowLayout()
    searchCollectionView.collectionViewLayout = layout
    
    searchCollectionView.delegate = self
    searchCollectionView.dataSource = self
    searchCollectionView.register(UINib(nibName: "RecordCell", bundle: nil), forCellWithReuseIdentifier: RecordCollectionViewCell.identifier)
  }
  
  func checkIsEmpty() {
    if results.isEmpty {
      emptyView.isHidden = false
    } else {
      emptyView.isHidden = true
    }
  }

  func searchData() {
      print(#function)
    guard let env = environment else { return }
    results = env.cafeRepository.search(query: queryText)
  }
}

// MARK: - UICollectionViewDataSource
extension RecordSearchViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return results.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: RecordCollectionViewCell.identifier, for: indexPath) as? RecordCollectionViewCell else { return UICollectionViewCell() }
    checkIsEmpty()
    let item = results[indexPath.item]
    
    cell.backgroundImageView.image = loadImageFromDocumentDirectory(type: .cafe, imageName: "cafe_\(item._id).jpg") ?? UIImage.defaultCafeImage
    cell.cellConfigure(with: item)
    
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension RecordSearchViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return cellInsets
  }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchCollectionView.deselectItem(at: indexPath, animated: true)
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "addRecordVC") as? AddRecordViewController else { return }
        guard let env = environment else { return }
        
        let cafe = results[indexPath.item]
        vc.environment = env
        vc.cafe = cafe
        
        self.present(vc, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RecordSearchViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let screenSize = UIScreen.main.bounds.size
    let spacing = Metric.spacing * (Metric.cellForItemCount - 1 + 2)
    let width = (screenSize.width - spacing) / Metric.cellForItemCount
    
    return CGSize(width: width, height: width)
  }
}
