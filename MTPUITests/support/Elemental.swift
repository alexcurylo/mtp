// @copyright Trollwerks Inc.

import XCTest

protocol Elemental: Exposable {

    var element: XCUIElement { get }
    var match: XCUIElement { get }
    var type: XCUIElement.ElementType { get }
}

extension Elemental {

    var app: XCUIElementQuery {
        return type.app
    }

    var element: XCUIElement {
        return app.element(matching: type, identifier: identifier)
    }

    var match: XCUIElement {
        return element.firstMatch
    }
}

extension MainTabBar: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .bar:
            return .tabBar
        case .locations,
             .rankings,
             .profile:
            return .button
        }
    }
}
