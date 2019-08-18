// @copyright Trollwerks Inc.

import XCTest

extension UIAddPost: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close,
             .save:
            return .button
        }
    }
}
