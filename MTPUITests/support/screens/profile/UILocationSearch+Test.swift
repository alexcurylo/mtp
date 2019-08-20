// @copyright Trollwerks Inc.

import XCTest

extension UILocationSearch: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close:
            return .button
        }
    }
}
