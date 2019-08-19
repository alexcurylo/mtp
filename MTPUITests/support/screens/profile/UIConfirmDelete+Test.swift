// @copyright Trollwerks Inc.

import XCTest

extension UIConfirmDelete: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .cancel,
             .confirm:
            return .button
        }
    }
}
