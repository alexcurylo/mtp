// @copyright Trollwerks Inc.

import XCTest

extension UILogin: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .email:
             return .textField
        case .password:
             return .secureTextField
        case .close,
             .forgot,
             .login,
             .signup,
             .toggle:
            return .button
        }
    }
}
