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

extension MainTBCs: Elemental {

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
        default: return MainTBCs.bar.match.query(type: type)
        }
    }
}

extension LocationsVCs: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .nav:
            return .navigationBar
        case .filter,
             .nearby:
            return .button
        }
    }

    var container: XCUIElementQuery {
        switch self {
        case .nav: return app
        default: return LocationsVCs.nav.match.query(type: type)
        }
    }
}
