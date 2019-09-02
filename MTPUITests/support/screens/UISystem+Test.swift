// @copyright Trollwerks Inc.

import XCTest

extension UISystem: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .button:
            return .button
        case .menu:
            return .menuItem
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
        case .menu(let value): return value
        case .text(let value): return value
        }
    }
}
