// @copyright Trollwerks Inc.

import XCTest

extension UIMyProfile: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .nav:
            return .navigationBar
        case .edit,
             .settings:
            return .button
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .nav:
            return app
        case .edit,
             .settings:
            return UIMyProfile.nav.match.query(type: type)
        }
    }
}
