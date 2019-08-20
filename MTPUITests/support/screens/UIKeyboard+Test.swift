// @copyright Trollwerks Inc.

import XCTest

extension UIKeyboard: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .toolbar:
            return .toolbar
        case .back,
             .clear,
             .done,
             .next:
            return .button
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .toolbar: return app
        default: return UIKeyboard.toolbar.match.query(type: type)
        }
    }
}
