// @copyright Trollwerks Inc.

import XCTest

extension UIRankings: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .nav:
            return .navigationBar
        case .cancel,
             .filter,
             .find:
            return .button
        case .result:
            return .cell
        case .search:
            return .searchField
        }
    }

    var element: XCUIElement {
        switch self {
        case .cancel:
            return all["Cancel"]
        case .search:
            return all["Search travellers"]
        default:
            return identified
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .filter,
             .find:
            return UIRankings.nav.match.query(type: type)
        default:
            return all
        }
    }
}
