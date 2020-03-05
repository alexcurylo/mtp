// @copyright Trollwerks Inc.

import XCTest

extension XCUIElement {

    var origin: XCUICoordinate {
        coordinate(withNormalizedOffset: CGVector.zero)
    }

    func tap(x: CGFloat, y: CGFloat) {
        let dx = x > 0 ? x : frame.size.width + x
        let dy = y > 0 ? y : frame.size.height + y
        tap(at: CGVector(dx: dx, dy: dy))
    }

    func tap(at position: CGVector) {
        origin.withOffset(position).tap()
    }
}
