// @copyright Trollwerks Inc.

import XCTest

extension MyProfileVCs: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .menu:
            return .collectionView
        case .about,
             .counts,
             .photos,
             .posts:
            return .cell
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .menu: return app
        default: return MyProfileVCs.menu.match.query(type: type)
        }
    }
}
