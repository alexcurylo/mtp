// @copyright Trollwerks Inc.

import XCTest

/// ProfileAboutVC exposed items
extension UIProfileAbout: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .remaining,
             .visited:
            return .button
        }
    }
}
