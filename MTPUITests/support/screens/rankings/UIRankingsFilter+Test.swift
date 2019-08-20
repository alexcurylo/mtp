// @copyright Trollwerks Inc.

import XCTest

extension UIRankingsFilter: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close:
            return .button
        }
    }
}
