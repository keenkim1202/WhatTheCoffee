//
//  CoffeeListViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN
//

import UIKit
import Realm
import RealmSwift

// TODO: 커피 정렬하기 - 등록일 순 > 가나다 순
// TODO: 커피 이미지랑 카페기록 이미지 각자 폴더 만들어서 저장하도록 하기

class CoffeeListViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment? = nil
  var coffeeList: [Coffee] = [] { didSet { tableView.reloadData() } }
  
  // MARK: - UI
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var emptyView: UIView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
    fetchData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    fetchData()
    checkIsEmpty()
  }
  
  // MARK: - Configure
  func configure() {
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  func fetchData() {
    guard let env = environment else { return }
    coffeeList = env.coffeeRepository.fetch()
  }
  
  func checkIsEmpty() {
    if coffeeList.isEmpty {
      emptyView.isHidden = false
    } else {
      emptyView.isHidden = true
    }
  }
  
  // MARK: Swipe Actions
  func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
    let action = UIContextualAction(style: .destructive, title: "삭제") { action, view, success in
      self.deleteAlert("정말 삭제하시겠습니까?") {
        guard let env = self.environment else { return }
        let coffee = self.coffeeList[indexPath.row]
        env.coffeeRepository.remove(item: coffee)
        
        self.fetchData()
        self.checkIsEmpty()
      }
      success(true)
    }
    action.image = UIImage(systemName: "trash")
    action.backgroundColor = .systemRed
    
    return action
  }
  
  // MARK: - Actions
  @IBAction func onClose(_ sender: UIBarButtonItem) {
    print(#function)
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func onAdd(_ sender: UIBarButtonItem) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "addCoffeeVC") as! AddCoffeeViewController
    vc.environment = environment
    
    self.navigationController?.pushViewController(vc, animated: true)
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
    guard let env = environment else { return }
    
    let coffee = coffeeList[indexPath.row]
    vc.environment = env
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
    cell.coffeeImageView.image = loadImageFromDocumentDirectory(type: .coffee, imageName: "coffee_\(row._id).jpg") ?? UIImage.randomCoffeeImage
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let delete = deleteAction(at: indexPath)
    return UISwipeActionsConfiguration(actions:[delete])
  }
}
