// @copyright Trollwerks Inc.

import Foundation
import WebKit

/// Notification of title change
protocol TitleChangeDelegate: AnyObject {

    /// Notify of title change
    ///
    /// - Parameter title: New title
    func changed(title: String)
}

/// Page for displaying website associated with a place
final class LocationWebsiteVC: WKWebViewController {

    /// Title change handler
    weak var titleDelegate: TitleChangeDelegate?

    /// Construction by injection
    ///
    /// - Parameter mappable: Place
    init(mappable: Mappable) {
        var source: WKWebSource?
        if let webUrl = mappable.placeWebUrl {
            source = .remote(webUrl)
        }
        super.init(source: source)
        configure()
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    /// Actions to take after reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(screen: "Location WebView")
    }

    /// Handle navigation completing
    ///
    /// - Parameters:
    ///   - webView: Page displayer
    ///   - navigation: Navigation type
    override func webView(_ webView: WKWebView,
                          // swiftlint:disable:next implicitly_unwrapped_optional
                          didFinish navigation: WKNavigation!) {
        let page = webView.title ?? ""
        let display = page.isEmpty ? L.website() : page
        title = display
        titleDelegate?.changed(title: display)

        super.webView(webView, didFinish: navigation)
    }
}

// MARK: - Private

private extension LocationWebsiteVC {

    func configure() {
        title = L.websiteLoading()
        websiteTitleInNavigationBar = false
        toolbarItemTypes = []
    }
}
