// @copyright Trollwerks Inc.

import XCTest

extension UIAlert: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .button:
            return .button
        case .text:
            return .staticText
        }
    }

    var element: XCUIElement {
        return all[value]
    }

    private var value: String {
        switch self {
        case .button(let value): return value
        case .text(let value): return value
        }
    }
}
