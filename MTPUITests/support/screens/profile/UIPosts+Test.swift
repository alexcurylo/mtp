// @copyright Trollwerks Inc.

import XCTest

extension UIPosts: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .add:
            return .button
        }
    }
}
