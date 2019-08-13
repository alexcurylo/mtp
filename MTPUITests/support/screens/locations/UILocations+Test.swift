// @copyright Trollwerks Inc.

import XCTest

extension UILocations: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .nav:
            return .navigationBar
        case .filter,
             .nearby:
            return .button
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .nav: return app
        default: return UILocations.nav.match.query(type: type)
        }
    }
}
