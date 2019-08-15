// @copyright Trollwerks Inc.

import XCTest

extension UITerms: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .agree,
             .close:
            return .button
        }
    }
}
