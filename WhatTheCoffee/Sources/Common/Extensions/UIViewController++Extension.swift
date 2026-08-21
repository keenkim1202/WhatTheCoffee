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

// MARK: - Confirming Alert
extension UIViewController {
  typealias CompletionHandler = () -> Void
  
  func addAlert(_ title: String,_ message: String, completion: @escaping CompletionHandler) {
    UIAlertController
      .confirm(self, title: title, message: message, onConfirm: completion)
  }
  
  func deleteAlert(_ message: String, completion: @escaping CompletionHandler) {
    UIAlertController
      .confirm(self, title: "⚠️", message: message, onConfirm: completion)
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
