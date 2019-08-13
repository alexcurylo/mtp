// @copyright Trollwerks Inc.

import XCTest

extension UISignup: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .credentials:
            return .other
        case .email:
            return .textField
        case .password:
            return .secureTextField
        case .login,
             .signup:
            return .button
        }
    }
}
