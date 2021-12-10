//
//  SettingViewController.swift
//  WhatTheCoffee
//
//  Created by KEEN on 2021/11/30.
//

import UIKit

class SettingViewController: UIViewController {
  
  // MARK: - Properties
  var environment: Environment?
  let settingList: [String] = ["🧞‍♂️ 문의하기", "📝 개인정보 처리방침","📚 오픈소스 라이선스", "☕️ 기본 커피 이미지 불러오기"]
  
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
  
  // MARK: - Action
  
  @IBAction func onClose(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: - Extension-
// MARK: - TableViewDelegate
extension SettingViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == 3 {
      self.addAlert("커피목록에 존재여부와 관계없이\n 기존 이미지 모두 추가됩니다.\n그래도 추가하시겠습니까?") {
        if let env = self.environment {
          self.saveDefaultCoffee(env: env)
          self.showSuccessAlert("재추가에 성공하였습니다.")
        } else {
          self.showErrorAlert("재추가에 실패하였습니다.")
        }
      }
    } else {
      let vc = storyboard?.instantiateViewController(withIdentifier: "detailSettingVC") as! SettingDetailViewController
      vc.title = settingList[indexPath.row]
      vc.index = indexPath.row
      
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = .fullScreen
      self.present(nav, animated: true, completion: nil)
    }
  }
}

// MARK: - TableViewDataSource
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
