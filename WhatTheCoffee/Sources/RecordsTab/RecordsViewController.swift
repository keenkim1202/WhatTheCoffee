//
//  RecordsViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit

class RecordsViewController: UIViewController {
  
  // MARK: - Properties
  let cellInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
  let cellColors: [UIColor] = [.red, .blue, .yellow, .orange, .darkGray, .systemPink, .cyan, .brown]
  
  // MARK: - UI
  @IBOutlet weak var recordCollectionView: UICollectionView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    recordCollectionView.delegate = self
    recordCollectionView.dataSource = self
  }
  
  // MARK: - Actions
  
  @IBAction func onEdit(_ sender: UIBarButtonItem) {
    print(#function)
  }
  
  @IBAction func onAdd(_ sender: UIBarButtonItem) {
    print(#function)
  }
  
}

// MARK: Extension
// MARK: - UICollectionViewDelegate & UICollectionViewDelegateFlowLayout
extension RecordsViewController: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let width = collectionView.frame.width
      let itemsPerRow: CGFloat = 2
      
      let widthPadding = cellInsets.top * (itemsPerRow + 1)
      let cellWidth = (width - widthPadding) / itemsPerRow
    
      return CGSize(width: cellWidth, height: cellWidth)
  }
}

// MARK: - UICollectionViewDataSource
extension RecordsViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return cellColors.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = recordCollectionView.dequeueReusableCell(withReuseIdentifier: RecordCollectionViewCell.identifier, for: indexPath) as? RecordCollectionViewCell else { return UICollectionViewCell() }
    
    cell.backgroundColor = cellColors[indexPath.item]
    return cell
  }
  
}
