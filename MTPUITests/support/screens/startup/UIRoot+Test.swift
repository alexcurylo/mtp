// @copyright Trollwerks Inc.

import XCTest

extension UIRoot: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .login,
             .signup:
            return .button
        }
    }
}
