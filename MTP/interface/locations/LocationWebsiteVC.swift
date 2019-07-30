// @copyright Trollwerks Inc.

import Foundation
import WebKit

protocol TitleChangeDelegate: AnyObject {

    func changed(title: String)
}

final class LocationWebsiteVC: WKWebViewController {

    weak var titleDelegate: TitleChangeDelegate?

    init(mappable: Mappable) {
        let source: WKWebSource?
        switch mappable.placeWebUrl {
        case let webUrl?:
            source = .remote(webUrl)
        default:
            source = nil
        }
        super.init(source: source)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

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
