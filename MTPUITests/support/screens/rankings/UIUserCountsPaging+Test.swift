// @copyright Trollwerks Inc.

import XCTest

extension UIUserCountsPaging: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .menu:
            return .collectionView
        case .remaining,
             .visited:
            return .cell
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .menu: return all
        default: return UIUserCountsPaging.menu.match.query(type: type)
        }
    }
}
