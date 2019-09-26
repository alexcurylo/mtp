// @copyright Trollwerks Inc.

import XCTest

extension UIMain: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .bar:
            return .tabBar
        case .locations,
             .rankings,
             .myProfile:
            return .button
        }
    }

    var element: XCUIElement {
        switch self {
        case .bar:
            return identified
        // for 13.0, find by name
        case .locations:
            return all["Locations"]
        case .rankings:
            return all["Rankings"]
        case .myProfile:
            return all["My Profile"]
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .bar: return all
        default: return UIMain.bar.match.query(type: type)
        }
    }
}
