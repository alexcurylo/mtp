// @copyright Trollwerks Inc.

import XCTest

extension UIAddPhoto: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .camera,
             .close,
             .image,
             .save:
            return .button
        }
    }
}
