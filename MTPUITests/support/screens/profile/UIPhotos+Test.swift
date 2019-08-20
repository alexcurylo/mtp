// @copyright Trollwerks Inc.

import XCTest

extension UIPhotos: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .add:
            return .button
        }
    }
}
