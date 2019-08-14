// @copyright Trollwerks Inc.

import XCTest

extension UIRankings: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .nav:
            return .navigationBar
        case .filter,
             .search:
            return .button
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .nav:
            return app
        case .filter,
             .search:
            return UIRankings.nav.match.query(type: type)
        }
    }
}
