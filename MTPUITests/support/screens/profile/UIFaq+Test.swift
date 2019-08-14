// @copyright Trollwerks Inc.

import XCTest

extension UIFaq: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close:
            return .button
        }
    }
}
