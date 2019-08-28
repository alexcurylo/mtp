// @copyright Trollwerks Inc.

import XCTest

extension UIProfilePhotos: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close:
            return .button
        }
    }
}
