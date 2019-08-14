// @copyright Trollwerks Inc.

import XCTest

extension UISettings: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .about,
             .close,
             .faq:
            return .button
        }
    }
}
