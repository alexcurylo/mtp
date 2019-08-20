// @copyright Trollwerks Inc.

import XCTest

extension UILocationSearch: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .cancel,
             .close:
            return .button
        case .item:
            return .cell
        case .search:
            return .searchField
        }
    }

    var element: XCUIElement {
        switch self {
        case .cancel:
            return app["Cancel"]
        case .search:
            return XCUIApplication().tables.searchFields["Search"]
        default:
            return identified
        }
    }
}
