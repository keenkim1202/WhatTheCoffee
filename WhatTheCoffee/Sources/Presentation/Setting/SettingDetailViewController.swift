import UIKit
import WebKit

class SettingDetailViewController: BaseViewController {

  // MARK: - Properties
  private let urlString: String

  /// 뒤로/앞으로 버튼의 활성 상태를 웹뷰 이동에 맞춰 갱신한다.
  private var observations: [NSKeyValueObservation] = []

  /// 지금 화면에 표시 중인 내용이 있는지. 실패 안내를 띄울지 판단하는 데 쓴다.
  private var hasVisibleContent = false

  // MARK: - UI
  private let webView: WKWebView = {
    let wv = WKWebView()
    wv.translatesAutoresizingMaskIntoConstraints = false
    return wv
  }()

  private let failureLabel: UILabel = {
    let label = UILabel()
    label.text = "페이지를 불러오지 못했습니다."
    label.font = UIFont.GowunBatang(type: .regular, size: 15)
    label.textColor = .secondaryLabel
    label.textAlignment = .center
    label.isHidden = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var backButton = UIBarButtonItem(
    image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(onBack))

  private lazy var forwardButton = UIBarButtonItem(
    image: UIImage(systemName: "chevron.forward"), style: .plain, target: self, action: #selector(onForward))

  private lazy var reloadButton = UIBarButtonItem(
    image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(onReload))

  private lazy var shareButton = UIBarButtonItem(
    image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(onShare))

  private lazy var toolbar: UIToolbar = {
    let bar = UIToolbar()
    let flexible = { UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) }
    bar.items = [backButton, flexible(), forwardButton, flexible(), reloadButton, flexible(), shareButton]
    bar.tintColor = UIColor(named: "GreenMainColor")
    bar.translatesAutoresizingMaskIntoConstraints = false
    return bar
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
    view.addSubview(failureLabel)
    view.addSubview(toolbar)
    webView.navigationDelegate = self
    webView.uiDelegate = self
    webView.allowsBackForwardNavigationGestures = true
    configureToolbarState()

    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),

      toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

      failureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      failureLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      failureLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      failureLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
    ])
  }

  private func loadWeb(link: String) {
    // 카카오 로컬 API의 place_url은 http로 내려온다. ATS가 최초 요청을 막아
    // 서버의 https 리다이렉트까지 가지도 못하므로, 열기 전에 스킴을 올린다.
    guard var components = URLComponents(string: link) else {
      failureLabel.isHidden = false
      return
    }
    if components.scheme == "http" {
      components.scheme = "https"
    }

    guard let url = components.url else {
      failureLabel.isHidden = false
      return
    }
    webView.load(URLRequest(url: url))
  }

  private func configureToolbarState() {
    backButton.isEnabled = webView.canGoBack
    forwardButton.isEnabled = webView.canGoForward
    shareButton.isEnabled = webView.url != nil

    observations = [
      webView.observe(\.canGoBack, options: [.new]) { [weak self] webView, _ in
        self?.backButton.isEnabled = webView.canGoBack
      },
      webView.observe(\.canGoForward, options: [.new]) { [weak self] webView, _ in
        self?.forwardButton.isEnabled = webView.canGoForward
      },
      webView.observe(\.url, options: [.new]) { [weak self] webView, _ in
        self?.shareButton.isEnabled = webView.url != nil
      }
    ]
  }

  // MARK: - Action
  @objc private func onClose() {
    dismiss(animated: true)
  }

  @objc private func onBack() {
    webView.goBack()
  }

  @objc private func onForward() {
    webView.goForward()
  }

  @objc private func onReload() {
    // 로드 자체가 실패해 기록이 비어 있으면 처음 주소로 다시 시도한다.
    if webView.url == nil {
      loadWeb(link: urlString)
    } else {
      webView.reload()
    }
  }

  @objc private func onShare() {
    guard let url = webView.url else { return }

    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    if let popover = activityVC.popoverPresentationController {
      popover.barButtonItem = shareButton
    }
    present(activityVC, animated: true)
  }
}

// MARK: - WKNavigationDelegate
extension SettingDetailViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView,
               decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    guard let url = navigationAction.request.url, let scheme = url.scheme else {
      decisionHandler(.allow)
      return
    }

    // 웹뷰가 다룰 수 없는 스킴(지도앱, 앱 링크 등)은 외부 앱으로 넘긴다.
    // 그냥 두면 탭해도 아무 일도 일어나지 않는다.
    guard ["http", "https", "about"].contains(scheme) else {
      // canOpenURL은 LSApplicationQueriesSchemes에 없는 스킴이면 앱이 깔려 있어도 false다.
      // 미리 묻지 말고 열어본 뒤, 정말 열 곳이 없을 때만 알린다.
      UIApplication.shared.open(url, options: [:]) { [weak self] opened in
        guard !opened else { return }
        self?.showCannotOpenAlert()
      }
      decisionHandler(.cancel)
      return
    }

    decisionHandler(.allow)
  }

  func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    // 새 내용을 그리기 시작했다. 이전 페이지는 더 이상 화면에 없다.
    hasVisibleContent = true
    failureLabel.isHidden = true
  }

  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    // 이 단계의 실패는 아직 화면을 갈아엎기 전이라 이전 페이지가 그대로 남는다.
    // 볼 것이 남아 있으면 안내하지 않는다. 광고·추적 요청 실패가 대부분 여기로 온다.
    guard !hasVisibleContent else { return }
    showFailure(error)
  }

  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    // 커밋 후 실패라 지금 화면은 비었거나 깨진 상태다. 이전에 성공한 적이 있어도 알려야 한다.
    hasVisibleContent = false
    showFailure(error)
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    hasVisibleContent = true
    failureLabel.isHidden = true
  }

  /// 이동 중 취소(-999)는 새 요청이 이전 요청을 대체할 때 생기는 정상 흐름이라 제외한다.
  private func showFailure(_ error: Error) {
    guard (error as NSError).code != NSURLErrorCancelled else { return }
    failureLabel.isHidden = false
  }

  private func showCannotOpenAlert() {
    let alert = UIAlertController(title: nil, message: "이 링크를 열 수 있는 앱이 없습니다.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    present(alert, animated: true)
  }
}

// MARK: - WKUIDelegate
extension SettingDetailViewController: WKUIDelegate {
  func webView(_ webView: WKWebView,
               createWebViewWith configuration: WKWebViewConfiguration,
               for navigationAction: WKNavigationAction,
               windowFeatures: WKWindowFeatures) -> WKWebView? {
    // target="_blank" 링크는 새 창을 만들어주지 않으면 탭해도 반응이 없다. 이 웹뷰에서 연다.
    if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
      webView.load(URLRequest(url: url))
    }
    return nil
  }
}
