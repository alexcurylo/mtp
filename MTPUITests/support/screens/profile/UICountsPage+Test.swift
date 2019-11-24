// @copyright Trollwerks Inc.

import XCTest

/// CountsPageVC exposed items
extension UICountsPage: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .section:
            return .other
        case .group,
             .item:
            return .cell
        case .brand,
             .toggle:
            return .switch
        }
    }
}
