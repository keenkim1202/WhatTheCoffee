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
  let settingList: [String] = ["🧞‍♂️ 문의하기", "📝 개인정보 처리방침","📚 오픈소스 라이선스", "🧊 아이스 커피 이미지 불러오기", "☕️ 핫 커피 이미지 불러오기"]
  
  // MARK: - UI
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var versionLabel: UILabel!
  
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
    versionLabel.text = versionInfo()
  }
  
  func versionInfo() -> String {
    guard
      let dictionary = Bundle.main.infoDictionary,
      let version = dictionary["CFBundleShortVersionString"] as? String
    else { return "" }
    
    let versionAndBuild: String = "v \(version)"
    return versionAndBuild
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
    if indexPath.section == 3 {
      self.addAlert("🧊 아이스 커피 재추가", "커피목록에 존재여부와 관계없이\n 기존 이미지 모두 추가됩니다.") {
        if let env = self.environment {
          self.saveDefaultIceCoffee(env: env)
          self.showSuccessAlert("재추가에 성공하였습니다.")
        } else {
          self.showErrorAlert("재추가에 실패하였습니다.")
        }
      }
    } else if indexPath.section == 4 {
      self.addAlert("☕️ 핫 커피 재추가", "커피목록에 존재여부와 관계없이\n 기존 이미지 모두 추가됩니다.") {
        if let env = self.environment {
          self.saveDefaultHotCoffee(env: env)
          self.showSuccessAlert("재추가에 성공하였습니다.")
        } else {
          self.showErrorAlert("재추가에 실패하였습니다.")
        }
      }
    }else {
      let vc = storyboard?.instantiateViewController(withIdentifier: "detailSettingVC") as! SettingDetailViewController
      vc.title = settingList[indexPath.section]
      vc.index = indexPath.section
      
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = .fullScreen
      self.present(nav, animated: true, completion: nil)
    }
  }
}

// MARK: - TableViewDataSource
extension SettingViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return settingList.count
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier) as? SettingTableViewCell else { return UITableViewCell() }
    
    cell.titleLabel.text = settingList[indexPath.section]
    return cell
  }
}
