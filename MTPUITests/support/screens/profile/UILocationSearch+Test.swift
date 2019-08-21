// @copyright Trollwerks Inc.

import XCTest

extension UILocationSearch: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .cancel,
             .close:
            return .button
        case .result:
            return .cell
        case .search:
            return .searchField
        }
    }

    var element: XCUIElement {
        switch self {
        case .cancel:
            return all["Cancel"]
        case .search:
            return all["Search"]
        default:
            return identified
        }
    }
}
