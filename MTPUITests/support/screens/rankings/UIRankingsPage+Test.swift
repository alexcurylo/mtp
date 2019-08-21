// @copyright Trollwerks Inc.

import XCTest

extension UIRankingsPage: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .ranks:
            return .collectionView
        case .profile:
            return .staticText
        case .remaining,
             .visited:
            return .button
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .ranks:
            return all
        case .profile(let list, _),
             .remaining(let list, _),
             .visited(let list, _):
            return UIRankingsPage.ranks(list).match.query(type: type)
        }
    }
}
