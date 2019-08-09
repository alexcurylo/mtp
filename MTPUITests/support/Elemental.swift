// @copyright Trollwerks Inc.

import XCTest

protocol Elemental: Exposable {

    var type: XCUIElement.ElementType { get }
    var container: XCUIElementQuery { get }
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
