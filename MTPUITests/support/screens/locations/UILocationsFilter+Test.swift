// @copyright Trollwerks Inc.

import XCTest

extension UILocationsFilter: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close:
            return .button
        }
    }
}
