// @copyright Trollwerks Inc.

import XCTest

extension NearbyVCs: Elemental {

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
             .places: return app
        case .place:
            return NearbyVCs.places.match.query(type: type)
        }
    }
}
