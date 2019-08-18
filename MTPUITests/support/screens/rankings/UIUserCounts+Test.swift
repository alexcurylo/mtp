// @copyright Trollwerks Inc.

import XCTest

extension UIUserCounts: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close:
            return .button
        }
    }
}
