// @copyright Trollwerks Inc.

import XCTest

extension UILocations: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .nav:
            return .navigationBar
        case .result:
            return .cell
        case .cancel,
             .filter,
             .nearby:
            return .button
        case .search:
            return .searchField
        }
    }

    var element: XCUIElement {
        switch self {
        case .cancel:
            return UILocations.nav.match.buttons["Cancel"]
        case .search:
            return all["Search for a place"]
        default:
            return identified
        }
    }
}
