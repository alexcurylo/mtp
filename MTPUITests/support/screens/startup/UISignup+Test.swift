// @copyright Trollwerks Inc.

import XCTest

extension UISignup: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .credentials:
            return .other
        case .birthday,
             .country,
             .email,
             .first,
             .gender,
             .last,
             .location:
            return .textField
        case .confirm,
             .password:
            return .secureTextField
        case .close,
             .facebook,
             .login,
             .signup,
             .toggleConfirm,
             .togglePassword,
             .tos:
            return .button
        }
    }
}
