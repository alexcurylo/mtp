// @copyright Trollwerks Inc.

import XCTest

extension UILogin: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .email,
             .password:
            return .textField
        case .forgot:
            return .button
        }
    }
}
