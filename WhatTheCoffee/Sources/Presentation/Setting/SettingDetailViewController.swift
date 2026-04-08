import UIKit
import WebKit

class SettingDetailViewController: BaseViewController {

  // MARK: - Properties
  private let urlString: String

  // MARK: - UI
  private let webView: WKWebView = {
    let wv = WKWebView()
    wv.translatesAutoresizingMaskIntoConstraints = false
    return wv
  }()

  private static let settingURLs: [Int: String] = [
    0: "https://www.instagram.com/what.the_coffee/?hl=ko",
    1: "https://ossified-gas-bd2.notion.site/859dcf874bcf499c8d35b77d5a2877fe",
    2: "https://ossified-gas-bd2.notion.site/ff69f40b6f6940f0ba2282ada37b2546"
  ]

  // MARK: - Init
  init(index: Int) {
    self.urlString = Self.settingURLs[index] ?? ""
    super.init(nibName: nil, bundle: nil)
  }

  init(url: String) {
    self.urlString = url
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Life-Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNav()
    configureLayout()
    loadWeb(link: urlString)
  }

  // MARK: - Configure
  private func configureNav() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(onClose))
  }

  private func configureLayout() {
    view.backgroundColor = .systemBackground
    view.addSubview(webView)

    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  private func loadWeb(link: String) {
    guard let url = URL(string: link) else { return }
    webView.load(URLRequest(url: url))
  }

  // MARK: - Action
  @objc private func onClose() {
    dismiss(animated: true)
  }
}
