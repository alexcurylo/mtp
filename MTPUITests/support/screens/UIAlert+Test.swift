// @copyright Trollwerks Inc.

import XCTest

extension UIAlert: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .title,
             .subtitle:
            return .staticText
        case .button:
            return .button
        }
    }

    var element: XCUIElement {
        return app[value]
    }

    private var value: String {
        switch self {
        case .button(let value): return value
        case .title(let value): return value
        case .subtitle(let value): return value
        }
    }
}
