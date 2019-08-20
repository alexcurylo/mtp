// @copyright Trollwerks Inc.

import XCTest

extension UILoginFail: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .message:
            return .staticText
        case .forgot,
             .ok:
            return .button
        }
    }
}
