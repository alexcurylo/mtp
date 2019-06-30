// @copyright Trollwerks Inc.

// original: https://github.com/Meniny/WKWebViewController
// Copyright © 2018年 Meniny. All rights reserved.

import Anchorage
import WebKit

//swiftlint:disable file_length

enum WKWebSource: Equatable {

    case remote(URL)
    case file(URL, access: URL)
    case string(String, base: URL?)

    var url: URL? {
        switch self {
        case .remote(let url): return url
        case .file(let url, _): return url
        default: return nil
        }
    }

    var remoteURL: URL? {
        switch self {
        case .remote(let url): return url
        default: return nil
        }
    }

    var absoluteString: String? {
        switch self {
        case .remote(let url): return url.absoluteString
        case .file(let url, _): return url.absoluteString
        default: return nil
        }
    }
}

enum BarButtonItemType {

    case back
    case forward
    case reload
    case stop
    case activity
    case done
    case flexibleSpace
    case custom(icon: UIImage?, title: String?, action: (WKWebViewController) -> Void)
}

enum NavigationBarPosition: String, Equatable, Codable {

    case none
    case left
    case right
}

@objc enum NavigationType: Int, Equatable, Codable {

    case linkActivated
    case formSubmitted
    case backForward
    case reload
    case formResubmitted
    case other
}

private let estimatedProgressKeyPath = "estimatedProgress"
private let titleKeyPath = "title"
private let cookieKey = "Cookie"

private enum UrlsHandledByApp {

    static var hosts = ["itunes.apple.com"]
    static var schemes = ["tel", "mailto", "sms"]
    static var blank = true
}

@objc protocol WKWebViewControllerDelegate {

    @objc optional func webView(controller: WKWebViewController,
                                canDismiss url: URL) -> Bool
    @objc optional func webView(controller: WKWebViewController,
                                didStart url: URL)
    @objc optional func webView(controller: WKWebViewController,
                                didFinish url: URL)
    @objc optional func webView(controller: WKWebViewController,
                                didFail url: URL,
                                withError error: Error)
    @objc optional func webView(controller: WKWebViewController,
                                decidePolicy url: URL,
                                navigationType: NavigationType) -> Bool
}

class WKWebViewController: UIViewController, ServiceProvider {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(source: WKWebSource?) {
        super.init(nibName: nil, bundle: nil)
        self.source = source
    }

    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        self.source = .remote(url)
    }

    var source: WKWebSource?
    /// use `source` instead
    var url: URL?
    var tintColor: UIColor?
    var allowsFileURL = true
    weak var delegate: WKWebViewControllerDelegate?
    var bypassedSSLHosts: [String] = []
    var cookies: [HTTPCookie] = []
    var headers: [String: String] = [:]
    var customUserAgent: String? {
        didSet {
            guard let agent = userAgent else { return }
            webView.customUserAgent = agent
        }
    }
    var userAgent: String? {
        didSet {
            guard let originalUserAgent = originalUserAgent,
                  let userAgent = userAgent else { return }
            webView.customUserAgent = [originalUserAgent, userAgent].joined(separator: " ")
        }
    }
    var pureUserAgent: String? {
        didSet {
            guard let agent = pureUserAgent else { return }
            webView.customUserAgent = agent
        }
    }

    var websiteTitleInNavigationBar = true
    var doneBarButtonItemPosition: NavigationBarPosition = .right
    var leftNavigationBarItemTypes: [BarButtonItemType] = []
    var rightNavigationBarItemTypes: [BarButtonItemType] = []
    var toolbarItemTypes: [BarButtonItemType] = [.back, .forward, .reload, .activity]

    var backBarButtonItemImage: UIImage?
    var forwardBarButtonItemImage: UIImage?
    var reloadBarButtonItemImage: UIImage?
    var stopBarButtonItemImage: UIImage?
    var activityBarButtonItemImage: UIImage?

    private let webView = WKWebView(frame: .zero,
                                    configuration: WKWebViewConfiguration())
    private let progressView = UIProgressView(progressViewStyle: .default).with {
        $0.trackTintColor = UIColor(white: 1, alpha: 0)
    }

    typealias PreviousState = (tintColor: UIColor, hidden: Bool)

    fileprivate var previousNavigationBarState: PreviousState?
    fileprivate var previousToolbarState: PreviousState?

    fileprivate lazy var originalUserAgent = UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")

    fileprivate lazy var backBarButtonItem: UIBarButtonItem = {
        let bundle = Bundle(for: WKWebViewController.self)
        return UIBarButtonItem(
            image: backBarButtonItemImage ?? UIImage(named: "navPageBack",
                                                     in: bundle,
                                                     compatibleWith: nil),
            style: .plain,
            target: self,
            action: #selector(backDidClick(sender:))
        )
    }()

    fileprivate lazy var forwardBarButtonItem: UIBarButtonItem = {
        let bundle = Bundle(for: WKWebViewController.self)
        return UIBarButtonItem(
            image: forwardBarButtonItemImage ?? UIImage(named: "navPageForward",
                                                        in: bundle,
                                                        compatibleWith: nil),
            style: .plain,
            target: self,
            action: #selector(forwardDidClick(sender:))
        )
    }()

    fileprivate lazy var reloadBarButtonItem: UIBarButtonItem = {
        if let image = reloadBarButtonItemImage {
            return UIBarButtonItem(image: image,
                                   style: .plain,
                                   target: self,
                                   action: #selector(reloadDidClick(sender:)))
        } else {
            return UIBarButtonItem(barButtonSystemItem: .refresh,
                                   target: self,
                                   action: #selector(reloadDidClick(sender:)))
        }
    }()

    fileprivate lazy var stopBarButtonItem: UIBarButtonItem = {
        if let image = stopBarButtonItemImage {
            return UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(stopDidClick(sender:)))
        } else {
            return UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopDidClick(sender:)))
        }
    }()

    fileprivate lazy var activityBarButtonItem: UIBarButtonItem = {
        if let image = activityBarButtonItemImage {
            return UIBarButtonItem(image: image,
                                   style: .plain,
                                   target: self,
                                   action: #selector(activityDidClick(sender:)))
        } else {
            return UIBarButtonItem(barButtonSystemItem: .action,
                                   target: self,
                                   action: #selector(activityDidClick(sender:)))
        }
    }()

    fileprivate lazy var doneBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneDidClick(sender:)))
    }()

    fileprivate lazy var flexibleSpaceBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }()

    deinit {
        webView.removeObserver(self, forKeyPath: estimatedProgressKeyPath)
        if websiteTitleInNavigationBar {
            webView.removeObserver(self, forKeyPath: titleKeyPath)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = [.bottom]

        webView.uiDelegate = self
        webView.navigationDelegate = self

        webView.allowsBackForwardNavigationGestures = true
        webView.isMultipleTouchEnabled = true

        webView.addObserver(self, forKeyPath: estimatedProgressKeyPath, options: .new, context: nil)
        if websiteTitleInNavigationBar {
            webView.addObserver(self, forKeyPath: titleKeyPath, options: .new, context: nil)
        }

        webView.customUserAgent = self.customUserAgent ?? self.userAgent ?? self.originalUserAgent

        self.navigationItem.title = self.navigationItem.title ?? self.source?.absoluteString

        if let navigation = self.navigationController {
            self.previousNavigationBarState = (navigation.navigationBar.tintColor, navigation.navigationBar.isHidden)
            self.previousToolbarState = (navigation.toolbar.tintColor, navigation.toolbar.isHidden)
        }

        self.setUpConstraints()
        self.addBarButtonItems()

        if let s = self.source {
            self.load(source: s)
        } else {
            log.error("[\(type(of: self))][Error] Invalid url")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        rollbackState()
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    // swiftlint:disable:next block_based_kvo
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               // swiftlint:disable:next discouraged_optional_collection
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case estimatedProgressKeyPath?:
            let estimatedProgress = webView.estimatedProgress
            progressView.alpha = 1
            progressView.setProgress(Float(estimatedProgress), animated: true)

            if estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3,
                               delay: 0.3,
                               options: .curveEaseOut,
                               animations: {
                                self.progressView.alpha = 0
                }, completion: { _ in
                    self.progressView.setProgress(0, animated: false)
                })
            }
        case titleKeyPath?:
            navigationItem.title = webView.title
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

// MARK: - Public Methods

extension WKWebViewController {

    func load(source s: WKWebSource) {
        switch s {
        case .remote(let url):
            self.load(remote: url)
        case let .file(url, access: access):
            self.load(file: url, access: access)
        case let .string(str, base: base):
            self.load(string: str, base: base)
        }
    }

    func load(remote: URL) {
        webView.load(createRequest(url: remote))
    }

    func load(file: URL, access: URL) {
        webView.loadFileURL(file, allowingReadAccessTo: access)
    }

    func load(string: String, base: URL? = nil) {
        webView.loadHTMLString(string, baseURL: base)
    }

    func goBackToFirstPage() {
        if let firstPageItem = webView.backForwardList.backList.first {
            webView.go(to: firstPageItem)
        }
    }
}

// MARK: - Fileprivate Methods

fileprivate extension WKWebViewController {

    var availableCookies: [HTTPCookie] {
        return cookies.filter { cookie in
            var result = true
            let url = self.source?.remoteURL
            if let host = url?.host, !cookie.domain.hasSuffix(host) {
                result = false
            }
            if cookie.isSecure && url?.scheme != "https" {
                result = false
            }

            return result
        }
    }

    func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)

        // Set up headers
        if !headers.isEmpty {
            for (field, value) in headers {
                request.addValue(value, forHTTPHeaderField: field)
            }
        }

        // Set up Cookies
        let cookies = availableCookies
        if !cookies.isEmpty,
           let value = HTTPCookie.requestHeaderFields(with: cookies)[cookieKey] {
            request.addValue(value, forHTTPHeaderField: cookieKey)
        }

        return request
    }

    func setUpConstraints() {
        view.addSubview(webView)
        webView.edgeAnchors == view.edgeAnchors

        view.addSubview(progressView)
        progressView.horizontalAnchors == view.horizontalAnchors
        progressView.topAnchor == view.topAnchor
    }

    // swiftlint:disable:next function_body_length
    func addBarButtonItems() {
        func barButtonItem(_ type: BarButtonItemType) -> UIBarButtonItem? {
            switch type {
            case .back:
                return backBarButtonItem
            case .forward:
                return forwardBarButtonItem
            case .reload:
                return reloadBarButtonItem
            case .stop:
                return stopBarButtonItem
            case .activity:
                return activityBarButtonItem
            case .done:
                return doneBarButtonItem
            case .flexibleSpace:
                return flexibleSpaceBarButtonItem
            case let .custom(icon, title, action):
                let item: BlockBarButtonItem
                if let icon = icon {
                    item = BlockBarButtonItem(image: icon,
                                              style: .plain,
                                              target: self,
                                              action: #selector(customDidClick(sender:)))
                } else {
                    item = BlockBarButtonItem(title: title,
                                              style: .plain,
                                              target: self,
                                              action: #selector(customDidClick(sender:)))
                }
                item.block = action
                return item
            }
        }

        if presentingViewController != nil {
            switch doneBarButtonItemPosition {
            case .left:
                if !leftNavigationBarItemTypes.contains(where: { type in
                    switch type {
                    case .done:
                        return true
                    default:
                        return false
                    }
                }) {
                    leftNavigationBarItemTypes.insert(.done, at: 0)
                }
            case .right:
                if !rightNavigationBarItemTypes.contains(where: { type in
                    switch type {
                    case .done:
                        return true
                    default:
                        return false
                    }
                }) {
                    rightNavigationBarItemTypes.insert(.done, at: 0)
                }
            case .none:
                break
            }
        }

        navigationItem.leftBarButtonItems = leftNavigationBarItemTypes.map { barButtonItemType in
            if let barButtonItem = barButtonItem(barButtonItemType) {
                return barButtonItem
            }
            return UIBarButtonItem()
        }

        navigationItem.rightBarButtonItems = rightNavigationBarItemTypes.map { barButtonItemType in
            if let barButtonItem = barButtonItem(barButtonItemType) {
                return barButtonItem
            }
            return UIBarButtonItem()
        }

        if !toolbarItemTypes.isEmpty {
            for index in 0..<toolbarItemTypes.count - 1 {
                toolbarItemTypes.insert(.flexibleSpace, at: 2 * index + 1)
            }
        }

        setToolbarItems(toolbarItemTypes.map { barButtonItemType -> UIBarButtonItem in
            if let barButtonItem = barButtonItem(barButtonItemType) {
                return barButtonItem
            }
            return UIBarButtonItem()
        }, animated: true)
    }

    func updateBarButtonItems() {
        backBarButtonItem.isEnabled = webView.canGoBack
        forwardBarButtonItem.isEnabled = webView.canGoForward

        let updateReloadBarButtonItem: (UIBarButtonItem, Bool) -> UIBarButtonItem = {
            [weak self] barButtonItem, isLoading in
            guard let self = self else { return barButtonItem }
            switch barButtonItem {
            case self.reloadBarButtonItem, self.stopBarButtonItem:
                return isLoading ? self.stopBarButtonItem : self.reloadBarButtonItem
            default:
                return barButtonItem
            }
        }

        let isLoading = webView.isLoading
        toolbarItems = toolbarItems?.map {
            updateReloadBarButtonItem($0, isLoading)
        }
        navigationItem.leftBarButtonItems = navigationItem.leftBarButtonItems?.map {
            updateReloadBarButtonItem($0, isLoading)
        }
        navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems?.map {
            updateReloadBarButtonItem($0, isLoading)
        }
    }

    func setUpState() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setToolbarHidden(toolbarItemTypes.isEmpty, animated: true)

        if let tintColor = tintColor {
            progressView.progressTintColor = tintColor
            navigationController?.navigationBar.tintColor = tintColor
            navigationController?.toolbar.tintColor = tintColor
        }
    }

    func rollbackState() {
        progressView.progress = 0

        guard let nav = navigationController else { return }

        if let prevToolbar = previousToolbarState {
            nav.toolbar.tintColor = prevToolbar.tintColor
            nav.setToolbarHidden(prevToolbar.hidden, animated: true)
        }
        if let prevNavbar = previousNavigationBarState {
            nav.navigationBar.tintColor = prevNavbar.tintColor
            nav.setNavigationBarHidden(prevNavbar.hidden, animated: true)
        }
    }

    func checkRequestCookies(_ request: URLRequest, cookies: [HTTPCookie]) -> Bool {
        if cookies.isEmpty {
            return true
        }
        guard let headerFields = request.allHTTPHeaderFields, let cookieString = headerFields[cookieKey] else {
            return false
        }

        let requestCookies = cookieString.components(separatedBy: ";").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: "=", maxSplits: 1).map(String.init)
        }

        var valid = false
        for cookie in cookies {
            valid = !requestCookies.filter {
                $0[0] == cookie.name && $0[1] == cookie.value
            }.isEmpty
            if !valid {
                break
            }
        }
        return valid
    }

    func openURLWithApp(_ url: URL) -> Bool {
        app.launch(url: url)
        return false
    }

    func handleURLWithApp(_ url: URL, targetFrame: WKFrameInfo?) -> Bool {
        let hosts = UrlsHandledByApp.hosts
        let schemes = UrlsHandledByApp.schemes
        let blank = UrlsHandledByApp.blank

        var tryToOpenURLWithApp = false
        if let host = url.host, hosts.contains(host) {
            tryToOpenURLWithApp = true
        }
        if let scheme = url.scheme, schemes.contains(scheme) {
            tryToOpenURLWithApp = true
        }
        if blank && targetFrame == nil {
            tryToOpenURLWithApp = true
        }

        return tryToOpenURLWithApp ? openURLWithApp(url) : false
    }

    @objc func backDidClick(sender: AnyObject) {
        webView.goBack()
    }

    @objc func forwardDidClick(sender: AnyObject) {
        webView.goForward()
    }

    @objc func reloadDidClick(sender: AnyObject) {
        webView.stopLoading()
        if webView.url != nil {
            webView.reload()
        } else if let s = self.source {
            self.load(source: s)
        }
    }

    @objc func stopDidClick(sender: AnyObject) {
        webView.stopLoading()
    }

    @objc func activityDidClick(sender: AnyObject) {
        guard let s = self.source else {
            return
        }

        let items: [Any]
        switch s {
        case .remote(let u):
            items = [u]
        case .file(let u, access: _):
            items = [u]
        case .string(let str, base: _):
            items = [str]
        }

        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }

    @objc func doneDidClick(sender: AnyObject) {
        var canDismiss = true
        if let url = self.source?.url {
            canDismiss = delegate?.webView?(controller: self, canDismiss: url) ?? true
        }
        if canDismiss {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc func customDidClick(sender: BlockBarButtonItem) {
        sender.block?(self)
    }
}

// MARK: - WKUIDelegate

extension WKWebViewController: WKUIDelegate {
}

// MARK: - WKNavigationDelegate

extension WKWebViewController: WKNavigationDelegate {

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateBarButtonItems()
        progressView.progress = 0
        if let u = webView.url {
            self.url = u
            delegate?.webView?(controller: self, didStart: u)
        }
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateBarButtonItems()
        progressView.progress = 0
        if let url = webView.url {
            self.url = url
            delegate?.webView?(controller: self, didFinish: url)
        }
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        updateBarButtonItems()
        progressView.progress = 0
        if let url = webView.url {
            self.url = url
            delegate?.webView?(controller: self, didFail: url, withError: error)
        }
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateBarButtonItems()
        progressView.progress = 0
        if let url = webView.url {
            self.url = url
            delegate?.webView?(controller: self, didFail: url, withError: error)
        }
    }

    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if bypassedSSLHosts.contains(challenge.protectionSpace.host),
           let trust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var actionPolicy: WKNavigationActionPolicy = .allow
        defer {
            decisionHandler(actionPolicy)
        }
        guard let u = navigationAction.request.url else {
            log.error("Cannot handle empty URLs")
            return
        }

        if !self.allowsFileURL && u.isFileURL {
            log.error("Cannot handle file URLs")
            return
        }

        if handleURLWithApp(u, targetFrame: navigationAction.targetFrame) {
            actionPolicy = .cancel
            return
        }

       let cookies = availableCookies
       if u.host == self.source?.url?.host,
          !cookies.isEmpty,
          !checkRequestCookies(navigationAction.request, cookies: cookies) {
            self.load(remote: u)
            actionPolicy = .cancel
            return
        }

        if let navigationType = NavigationType(rawValue: navigationAction.navigationType.rawValue),
           let result = delegate?.webView?(controller: self,
                                           decidePolicy: u,
                                           navigationType: navigationType) {
            actionPolicy = result ? .allow : .cancel
        }
    }
}

final class BlockBarButtonItem: UIBarButtonItem {

    var block: ((WKWebViewController) -> Void)?
}
