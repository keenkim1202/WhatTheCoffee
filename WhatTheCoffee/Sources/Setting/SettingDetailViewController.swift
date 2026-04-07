import UIKit
import WebKit

class SettingDetailViewController: BaseViewController {
  
  // MARK: - Properties
  var index: Int?
  var url: String?
  
  // MARK: - UI
  @IBOutlet weak var webView: WKWebView!
  
  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if index == 0 {
      loadWeb(link: "https://www.instagram.com/what.the_coffee/?hl=ko")
    } else if index == 1 {
      loadWeb(link: "https://ossified-gas-bd2.notion.site/859dcf874bcf499c8d35b77d5a2877fe")
    } else if index == 2 {
      loadWeb(link: "https://ossified-gas-bd2.notion.site/ff69f40b6f6940f0ba2282ada37b2546")
    } else {
      loadWeb(link: url!)
    }
  }
  
  func loadWeb(link: String) {
    guard let url = URL(string: link) else { return }
    
    let request = URLRequest(url: url)
    webView.load(request)
  }
  
  // MARK: - Action
  @IBAction func onClose(_ sender: UIBarButtonItem) {
      self.dismiss(animated: true)
  }
  
}
