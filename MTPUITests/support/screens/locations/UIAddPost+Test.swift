// @copyright Trollwerks Inc.

import XCTest

extension UIAddPost: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close,
             .save:
            return .button
        case .country,
             .location:
            return .textField
        case .post:
            return .textView
        }
    }
}
