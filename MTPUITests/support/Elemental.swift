// @copyright Trollwerks Inc.

import XCTest

protocol Elemental: Exposable {

    var container: XCUIElementQuery { get }
    var element: XCUIElement { get }
    var match: XCUIElement { get }
    var type: XCUIElement.ElementType { get }
}

extension Elemental {

    var app: XCUIElementQuery {
        return type.app
    }

    var container: XCUIElementQuery {
        return app
    }

    var element: XCUIElement {
        return container.element(matching: type, identifier: identifier)
    }

    var match: XCUIElement {
        return element.firstMatch
    }
}
