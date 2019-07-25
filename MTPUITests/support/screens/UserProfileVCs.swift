// @copyright Trollwerks Inc.

import XCTest

extension UserProfileVCs: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close:
            return .button
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .close: return app
        }
    }
}
