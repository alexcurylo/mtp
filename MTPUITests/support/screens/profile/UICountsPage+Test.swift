// @copyright Trollwerks Inc.

import XCTest

/// CountsPageVC exposed items
extension UICountsPage: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .region:
            return .other
        case .group,
             .item:
            return .cell
        case .toggle:
            return .switch
        }
    }
}
