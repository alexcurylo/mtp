// @copyright Trollwerks Inc.

import Foundation

final class LocationWebsiteVC: WKWebViewController {

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
}

private extension LocationWebsiteVC {

    func configure() {
        title = L.website()
        websiteTitleInNavigationBar = false
        toolbarItemTypes = []
    }
}
