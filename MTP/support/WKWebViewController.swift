// @copyright Trollwerks Inc.

// original: https://github.com/Meniny/WKWebViewController
// Copyright © 2018年 Meniny. All rights reserved.

import Anchorage
import WebKit

//swiftlint:disable file_length

/// Source of web page data
enum WKWebSource: Equatable {

    /// A remote URL
    case remote(URL)
    /// A local URL
    case file(URL, access: URL)
    /// A string
    case string(String, base: URL?)

    /// source URL
    var url: URL? {
        switch self {
        case .remote(let url): return url
        case .file(let url, _): return url
        default: return nil
        }
    }

    /// source URL if remote
    var remoteURL: URL? {
        switch self {
        case .remote(let url): return url
        default: return nil
        }
    }

    /// String representation of URL
    var absoluteString: String? {
        switch self {
        case .remote(let url): return url.absoluteString
        case .file(let url, _): return url.absoluteString
        default: return nil
        }
    }
}

/// Supported bar buttons
enum BarButtonItemType {

    /// Back
    case back
    /// Forward
    case forward
    /// Reload
    case reload
    /// Stop
    case stop
    /// Activity
    case activity
    /// Done
    case done
    /// Spacer
    case flexibleSpace
    /// Custom
    case custom(icon: UIImage?, title: String?, action: (WKWebViewController) -> Void)
}

/// Navigation Bar Position
enum NavigationBarPosition: String, Equatable, Codable {

    /// None
    case none
    /// Left
    case left
    /// Right
    case right
}

/// Navigation type
@objc enum NavigationType: Int, Equatable, Codable {

    /// Link activated
    case linkActivated
    /// Form submitted
    case formSubmitted
    /// Back or Forward
    case backForward
    /// Reload
    case reload
    /// Form resubmitted
    case formResubmitted
    /// Other
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

/// Delegate functions
@objc protocol WKWebViewControllerDelegate {

    /// Dismissal permission
    ///
    /// - Parameters:
    ///   - controller: WKWebViewController
    ///   - url: Target URL
    /// - Returns: Permission
    @objc optional func webView(controller: WKWebViewController,
                                canDismiss url: URL) -> Bool
    /// Start notification
    ///
    /// - Parameters:
    ///   - controller: WKWebViewController
    ///   - url: Target URL
    @objc optional func webView(controller: WKWebViewController,
                                didStart url: URL)
    /// Finish notification
    ///
    /// - Parameters:
    ///   - controller: WKWebViewController
    ///   - url: Target URL
    @objc optional func webView(controller: WKWebViewController,
                                didFinish url: URL)
    /// Failure notification
    ///
    /// - Parameters:
    ///   - controller: WKWebViewController
    ///   - url: Target URL
    ///   - error: Error
    @objc optional func webView(controller: WKWebViewController,
                                didFail url: URL,
                                withError error: Error)
    /// Decide Policy
    ///
    /// - Parameters:
    ///   - controller: WKWebViewController
    ///   - url: Target URL
    ///   - navigationType: Navigation type
    /// - Returns: Whether allowed
    @objc optional func webView(controller: WKWebViewController,
                                decidePolicy url: URL,
                                navigationType: NavigationType) -> Bool
}

/// Provides WKWebView hosting support
class WKWebViewController: UIViewController {

    /// Default initializer
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    /// Decoding intializer
    ///
    /// - Parameter aDecoder: Decoder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// Source initializer
    ///
    /// - Parameter source: source
    init(source: WKWebSource?) {
        super.init(nibName: nil, bundle: nil)
        self.source = source
    }

    /// URL initializer
    ///
    /// - Parameter url: URL
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        self.source = .remote(url)
    }

    /// Page source
    var source: WKWebSource?
    /// Page URL - use `source` instead
    var url: URL?
    /// Tint Color
    var tintColor: UIColor?
    /// Allows local URLs
    var allowsFileURL = true
    /// Delegate
    weak var delegate: WKWebViewControllerDelegate?
    /// Bypassed SSL Hosts
    var bypassedSSLHosts: [String] = []
    /// Cookies
    var cookies: [HTTPCookie] = []
    /// Headers
    var headers: [String: String] = [:]
    /// Custom User Agent
    var customUserAgent: String? {
        didSet {
            guard let agent = userAgent else { return }
            webView.customUserAgent = agent
        }
    }
    /// User Agent
    var userAgent: String? {
        didSet {
            guard let originalUserAgent = originalUserAgent,
                  let userAgent = userAgent else { return }
            webView.customUserAgent = [originalUserAgent, userAgent].joined(separator: " ")
        }
    }
    /// Pure User Agent
    var pureUserAgent: String? {
        didSet {
            guard let agent = pureUserAgent else { return }
            webView.customUserAgent = agent
        }
    }

    /// Show title in navigation bar
    var websiteTitleInNavigationBar = true
    /// Done button position
    var doneBarButtonItemPosition: NavigationBarPosition = .right
    /// Left nav bar items
    var leftNavigationBarItemTypes: [BarButtonItemType] = []
    /// Right nav bar items
    var rightNavigationBarItemTypes: [BarButtonItemType] = []
    /// Toolbar items
    var toolbarItemTypes: [BarButtonItemType] = [.back, .forward, .reload, .activity]

    /// Back button image
    var backBarButtonItemImage: UIImage?
    /// Forward button image
    var forwardBarButtonItemImage: UIImage?
    /// Reload button image
    var reloadBarButtonItemImage: UIImage?
    /// Stop button image
    var stopBarButtonItemImage: UIImage?
    /// Activity button image
    var activityBarButtonItemImage: UIImage?

    private let webView = WKWebView(frame: .zero,
                                    configuration: WKWebViewConfiguration())
    private let progressView = UIProgressView(progressViewStyle: .default).with {
        $0.trackTintColor = UIColor(white: 1, alpha: 0)
    }

    fileprivate typealias PreviousState = (tintColor: UIColor, hidden: Bool)

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

    private var isObserving = false

    /// Remove observers
    deinit {
        if isObserving {
            webView.removeObserver(self, forKeyPath: estimatedProgressKeyPath)
            if websiteTitleInNavigationBar {
                webView.removeObserver(self, forKeyPath: titleKeyPath)
            }
        }
    }

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = [.bottom]

        webView.uiDelegate = self
        webView.navigationDelegate = self

        webView.allowsBackForwardNavigationGestures = true
        webView.isMultipleTouchEnabled = true

        webView.addObserver(self,
                            forKeyPath: estimatedProgressKeyPath,
                            options: .new,
                            context: nil)
        if websiteTitleInNavigationBar {
            webView.addObserver(self,
                                forKeyPath: titleKeyPath,
                                options: .new,
                                context: nil)
        }
        isObserving = true

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
        }
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpState()
    }

    /// Prepare for hide
    ///
    /// - Parameter animated: Whether animating
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        rollbackState()
    }

    /// KVO observation
    ///
    /// - Parameters:
    ///   - keyPath: Path observed
    ///   - object: Object observed
    ///   - change: Change description
    ///   - context: Optional context
    override func observeValue(forKeyPath keyPath: String?,
                               // swiftlint:disable:previous block_based_kvo
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

    /// Load from source
    ///
    /// - Parameter source: source
    func load(source: WKWebSource) {
        switch source {
        case .remote(let url):
            load(remote: url)
        case let .file(url, access: access):
            load(file: url, access: access)
        case let .string(str, base: base):
            load(string: str, base: base)
        }
    }

    /// Load from remote URL
    ///
    /// - Parameter remote: URL
    func load(remote: URL) {
        webView.load(createRequest(url: remote))
    }

    /// Load from file
    ///
    /// - Parameters:
    ///   - file: File
    ///   - access: Read access
    func load(file: URL, access: URL) {
        webView.loadFileURL(file, allowingReadAccessTo: access)
    }

    /// Load from string
    ///
    /// - Parameters:
    ///   - string: Page to load
    ///   - base: Base URL
    func load(string: String, base: URL? = nil) {
        webView.loadHTMLString(string, baseURL: base)
    }

    /// Go back to first page
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
            let url = source?.remoteURL
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

    func checkRequestCookies(_ request: URLRequest,
                             cookies: [HTTPCookie]) -> Bool {
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
            valid = requestCookies.contains {
                $0[0] == cookie.name && $0[1] == cookie.value
            }
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

    func handleURLWithApp(_ url: URL,
                          targetFrame: WKFrameInfo?) -> Bool {
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
        } else if let source = source {
            load(source: source)
        }
    }

    @objc func stopDidClick(sender: AnyObject) {
        webView.stopLoading()
    }

    @objc func activityDidClick(sender: AnyObject) {
        guard let source = source else { return }

        let items: [Any]
        switch source {
        case .remote(let u):
            items = [u]
        case .file(let u, access: _):
            items = [u]
        case .string(let str, base: _):
            items = [str]
        }

        let activityViewController = UIActivityViewController(activityItems: items,
                                                              applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }

    @objc func doneDidClick(sender: AnyObject) {
        var canDismiss = true
        if let url = source?.url {
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

extension WKWebViewController: WKUIDelegate { }

// MARK: - WKNavigationDelegate

extension WKWebViewController: WKNavigationDelegate {

    /// Start navigation
    ///
    /// - Parameters:
    ///   - webView: Host view
    ///   - navigation: Navigation type
    func webView(_ webView: WKWebView,
                 // swiftlint:disable:next implicitly_unwrapped_optional
                 didStartProvisionalNavigation navigation: WKNavigation!) {
        updateBarButtonItems()
        progressView.progress = 0
        if let u = webView.url {
            self.url = u
            delegate?.webView?(controller: self, didStart: u)
        }
    }

    /// Finish navigation
    ///
    /// - Parameters:
    ///   - webView: Host view
    ///   - navigation: Navigation type
    func webView(_ webView: WKWebView,
                 // swiftlint:disable:next implicitly_unwrapped_optional
                 didFinish navigation: WKNavigation!) {
        updateBarButtonItems()
        progressView.progress = 0
        if let url = webView.url {
            self.url = url
            delegate?.webView?(controller: self, didFinish: url)
        }
    }

    /// Fail provisional navigation
    ///
    /// - Parameters:
    ///   - webView: Host view
    ///   - navigation: Navigation type
    ///   - error: Error
    func webView(_ webView: WKWebView,
                 // swiftlint:disable:next implicitly_unwrapped_optional
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        updateBarButtonItems()
        progressView.progress = 0
        if let url = webView.url {
            self.url = url
            delegate?.webView?(controller: self, didFail: url, withError: error)
        }
    }

    /// Fail navigation
    ///
    /// - Parameters:
    ///   - webView: Host view
    ///   - navigation: Navigation type
    ///   - error: Error
    func webView(_ webView: WKWebView,
                 // swiftlint:disable:next implicitly_unwrapped_optional
                 didFail navigation: WKNavigation!,
                 withError error: Error) {
        updateBarButtonItems()
        progressView.progress = 0
        if let url = webView.url {
            self.url = url
            delegate?.webView?(controller: self, didFail: url, withError: error)
        }
    }

    /// Handle challenge
    ///
    /// - Parameters:
    ///   - webView: Host view
    ///   - challenge: Challenge
    ///   - completionHandler: Handler
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

    /// Decide navigation policy
    ///
    /// - Parameters:
    ///   - webView: Host view
    ///   - navigationAction: Action
    ///   - decisionHandler: Handler
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

private class BlockBarButtonItem: UIBarButtonItem {

    var block: ((WKWebViewController) -> Void)?
}
