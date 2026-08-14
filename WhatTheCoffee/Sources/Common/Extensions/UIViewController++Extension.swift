import UIKit

// MARK: - Configuring Alert
extension UIViewController {
  func showErrorAlert(_ message: String) {
    UIAlertController
      .show(self, contentType: .error, message: message)
  }
  
  func showSuccessAlert(_ message: String) {
    UIAlertController
      .show(self, contentType: .success, message: message)
  }
  
  func errorAlert(error: AppError) {
    self.present(error.alert, animated: true)
  }
}

// MARK: - Delete Alert
extension UIViewController {
  typealias CompletionHandler = () -> Void
  
  // TODO: deleteAlert, addAlert 비슷함. 코드 줄일 수 있을 것 같음. 나중에 고치기.
  func addAlert(_ title: String,_ message: String, completion: @escaping CompletionHandler) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let no = UIAlertAction(title: "아니오", style: .default, handler: nil)
    let yes = UIAlertAction(title: "네", style: .destructive) { _ in
      completion()
    }
    
    alert.addAction(no)
    alert.addAction(yes)
    
    self.present(alert, animated: true)
  }
  
  func deleteAlert(_ message: String, completion: @escaping CompletionHandler) {
    let alert = UIAlertController(title: "⚠️", message: message, preferredStyle: .alert)
    let no = UIAlertAction(title: "아니오", style: .default, handler: nil)
    let yes = UIAlertAction(title: "네", style: .destructive) { _ in
      completion()
    }
    
    alert.addAction(no)
    alert.addAction(yes)
    
    self.present(alert, animated: true)
  }
}

// MARK: - NavigationBar Font Configure
extension UIViewController {
  func adjustNavigationBarFont() {
    self.navigationController?.navigationBar.titleTextAttributes = [
      NSAttributedString.Key.font: UIFont(name: "GowunBatang-Bold", size: 17)!
    ]
    
    let BarButtonTextAttributes: [NSAttributedString.Key: Any] = [
      .font: UIFont(name: "GowunBatang-Bold", size: 16)!
    ]
    
    if let leftBarButtons = self.navigationItem.leftBarButtonItems {
      for button in leftBarButtons {
        button.setTitleTextAttributes(BarButtonTextAttributes, for: .normal)
        button.setTitleTextAttributes(BarButtonTextAttributes, for: .highlighted)
      }
    }
    
    if let rightBarButtons = self.navigationItem.rightBarButtonItems {
      for button in rightBarButtons {
        button.setTitleTextAttributes(BarButtonTextAttributes, for: .normal)
        button.setTitleTextAttributes(BarButtonTextAttributes, for: .highlighted)
      }
    }
  }
}
