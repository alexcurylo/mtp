// @copyright Trollwerks Inc.

import XCTest

extension UIMyProfile: Elemental {

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
        default: return UIMyProfile.menu.match.query(type: type)
        }
    }
}
