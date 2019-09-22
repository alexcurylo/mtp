// @copyright Trollwerks Inc.

import XCTest

extension UINetwork: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close:
            return .button
        }
    }
}
