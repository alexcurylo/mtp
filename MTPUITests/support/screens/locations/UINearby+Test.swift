// @copyright Trollwerks Inc.

import XCTest

extension UINearby: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .close:
            return .button
        case .places:
            return .table
        case .place:
            return .cell
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .close,
             .places: return all
        case .place:
            return UINearby.places.match.query(type: type)
        }
    }
}
