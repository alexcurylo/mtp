// @copyright Trollwerks Inc.

import XCTest

extension UIRankingsPaging: Elemental {

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
        case .menu: return all
        default: return UIRankingsPaging.menu.match.query(type: type)
        }
    }
}
