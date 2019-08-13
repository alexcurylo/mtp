// @copyright Trollwerks Inc.

import XCTest

extension UIUserProfile: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close:
            return .button
        }
    }
}
