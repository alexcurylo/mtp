// @copyright Trollwerks Inc.

import XCTest

extension UIAddPhoto: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close,
             .save:
            return .button
        }
    }
}
