// @copyright Trollwerks Inc.

import XCTest

extension UISignup: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .credentials:
            return .other
        case .email,
             .first,
             .last:
            return .textField
        case .confirm,
             .password:
            return .secureTextField
        case .close,
             .login,
             .signup,
             .toggleConfirm,
             .togglePassword,
             .tos:
            return .button
        }
    }
}
