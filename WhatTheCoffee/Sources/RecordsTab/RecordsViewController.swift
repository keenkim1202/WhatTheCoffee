//
//  RecordsViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit

class RecordsViewController: UIViewController {
  
  // MARK: - Metric
  struct Metric {
    static var spacing: CGFloat = 10
    static var cellForItemCount: CGFloat = 2
  }
  
  // MARK: - Properties
  var environment: Environment? = nil
  
  let cellInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
  let cellColors: [UIColor] = [.red, .blue, .yellow, .orange, .darkGray, .systemPink, .cyan, .brown]
  
  // MARK: - UI
  @IBOutlet weak var recordCollectionView: UICollectionView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
  
  // MARK: - Configure
  func configure() {
    let layout = UICollectionViewFlowLayout()
    recordCollectionView.collectionViewLayout = layout
    
    recordCollectionView.delegate = self
    recordCollectionView.dataSource = self
    recordCollectionView.register(
      UINib(nibName: "RecordCell", bundle: nil),
      forCellWithReuseIdentifier: RecordCollectionViewCell.identifier
    )
  }
  
  // MARK: - Actions
  @IBAction func onEdit(_ sender: UIBarButtonItem) {
    print(#function)
  }
  
  @IBAction func onAdd(_ sender: UIBarButtonItem) {
    print(#function)
    let vc = storyboard?.instantiateViewController(withIdentifier: "addRecordVC") as! AddRecordViewController
    vc.environment = environment

    self.navigationController?.pushViewController(vc, animated: true)
  }
  
}

// MARK: Extension
// MARK: - UICollectionViewDelegate
extension RecordsViewController: UICollectionViewDelegate {

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

// MARK: - UICollectionViewDelegateFlowLayout
extension RecordsViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let screenSize = UIScreen.main.bounds.size
    let spacing = Metric.spacing * (Metric.cellForItemCount - 1)
    let width = (screenSize.width - spacing) / Metric.cellForItemCount

    return CGSize(width: width, height: width)
  }
}
