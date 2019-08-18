// @copyright Trollwerks Inc.

import XCTest

extension UIAppAbout: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close:
            return .button
        }
    }
}
