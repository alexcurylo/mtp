// @copyright Trollwerks Inc.

import XCTest

extension LocationsVCs: Elemental {

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
        default: return LocationsVCs.nav.match.query(type: type)
        }
    }
}
