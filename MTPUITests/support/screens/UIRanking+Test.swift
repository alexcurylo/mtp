// @copyright Trollwerks Inc.

import XCTest

extension UIRanking: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .nav:
            return .navigationBar
        case .ranks:
            return .collectionView
        case .profile:
            return .staticText
        case .filter,
             .remaining,
             .search,
             .visited:
            return .button
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .nav,
             .ranks:
            return app
        case .profile(let list, _),
             .remaining(let list, _),
             .visited(let list, _):
            return UIRanking.ranks(list).match.query(type: type)
        case .filter,
             .search:
            return UIRanking.nav.match.query(type: type)
        }
    }
}
