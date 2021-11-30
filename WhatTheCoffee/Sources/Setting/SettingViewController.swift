//
//  SettingViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/30.
//

import UIKit

class SettingViewController: UIViewController {
  
  // MARK: - Properties
  let settingList: [String] = ["🧞‍♂️ 문의하기", "📝 개인정보 처리방침","📚 오픈소스 라이선스"]
  
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
    
    adjustNavigationBarFont()
  }
  
}

extension SettingViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = storyboard?.instantiateViewController(withIdentifier: "detailSettingVC") as! SettingDetailViewController
    vc.title = settingList[indexPath.row]
    vc.index = indexPath.row
    
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    self.present(nav, animated: true, completion: nil)
  }
}

extension SettingViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return settingList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier) as? SettingTableViewCell else { return UITableViewCell() }
    cell.titleLabel.text = settingList[indexPath.row]
    return cell
  }
}
