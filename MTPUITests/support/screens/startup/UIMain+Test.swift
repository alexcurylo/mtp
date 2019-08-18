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

    var container: XCUIElementQuery {
        switch self {
        case .bar: return app
        default: return UIMain.bar.match.query(type: type)
        }
    }
}
