// @copyright Trollwerks Inc.

import XCTest

extension UILocations: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .nav:
            return .navigationBar
        case .result:
            return .cell
        case .addPhoto,
             .addPost,
             .cancel,
             .close,
             .directions,
             .filter,
             .more,
             .nearbies,
             .nearby:
            return .button
        case .search:
            return .searchField
        case .visit:
            return .switch
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
