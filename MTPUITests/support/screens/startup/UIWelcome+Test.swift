// @copyright Trollwerks Inc.

import XCTest

extension UIWelcome: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .later,
             .profile:
            return .button
        }
    }
}
