// @copyright Trollwerks Inc.

import XCTest

extension UILocationPaging: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .menu:
            return .collectionView
        case .first,
             .photos,
             .posts:
            return .cell
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .menu: return all
        default: return UILocationPaging.menu.match.query(type: type)
        }
    }
}
