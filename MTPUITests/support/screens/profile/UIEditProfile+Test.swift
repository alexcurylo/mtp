// @copyright Trollwerks Inc.

import XCTest

extension UIEditProfile: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close,
             .save:
            return .button
        case .country:
            return .textField
        }
    }
}
