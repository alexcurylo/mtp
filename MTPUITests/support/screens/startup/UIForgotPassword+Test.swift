// @copyright Trollwerks Inc.

import XCTest

extension UIForgotPassword: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .cancel,
             .send:
            return .button
        }
    }
}
