// @copyright Trollwerks Inc.

import XCTest

extension UILocation: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close,
             .map:
            return .button
        }
    }
}
