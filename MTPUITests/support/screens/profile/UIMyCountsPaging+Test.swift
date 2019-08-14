// @copyright Trollwerks Inc.

import XCTest

extension UIMyCountsPaging: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .menu:
            return .collectionView
        case .page:
            return .cell
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .menu: return app
        default: return UIMyCountsPaging.menu.match.query(type: type)
        }
    }
}
