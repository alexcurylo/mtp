// @copyright Trollwerks Inc.

import XCTest

extension UISignupFail: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .message:
            return .staticText
        case .ok:
            return .button
        }
    }
}
