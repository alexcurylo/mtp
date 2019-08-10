// @copyright Trollwerks Inc.

import XCTest

protocol Elemental: Exposable {

    var type: XCUIElement.ElementType { get }
    var container: XCUIElementQuery { get }
}

enum ElementalState {

    case exists
    case hittable
    case selected
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

    var exists: Bool {
        return match.exists
    }

    var isHittable: Bool {
        return match.isHittable
    }

    var isSelected: Bool {
        return match.isSelected
    }

    @discardableResult func wait(timeout: TimeInterval = 5) -> XCUIElement {
        let matched = match
        XCTAssertTrue(matched.waitForExistence(timeout: timeout), "\(identifier) not found after \(timeout) seconds")
        return matched
    }

    func assert(_ state: ElementalState) {
        let matched = wait()
        let success: Bool
        switch state {
        case .exists:
            success = matched.exists
        case .hittable:
            success = matched.isHittable
        case .selected:
            success = matched.isSelected
        }
        XCTAssertTrue(success, "\(identifier) not \(state)")
    }

    func wait(for state: ElementalState,
              timeout: TimeInterval = 5) {
        let predicate: NSPredicate
        switch state {
        case .exists:
            wait(timeout: timeout)
            return
        case .hittable:
            predicate = NSPredicate(format: "selected == true")
        case .selected:
            predicate = NSPredicate(format: "selected == true")
        }
        let expectation = XCTNSPredicateExpectation(predicate: predicate,
                                                    object: match)
        let result = XCTWaiter.wait(for: [expectation],
                                    timeout: timeout)
        switch result {
        case .completed:
            return
        default:
            XCTFail("\(identifier) not \(state) after \(timeout) seconds because \(result)")
        }
    }

    func type(text: String) {
        wait().typeText(text)
    }

    // note foreseeable failure here:
    // https://openradar.appspot.com/26493495

    func tap() {
        wait().tap()
    }

    func doubleTap() {
        wait().doubleTap()
    }

    func twoFingerTap() {
        wait().twoFingerTap()
    }

    func tap(withNumberOfTaps numberOfTaps: Int,
             numberOfTouches: Int) {
        wait().tap(withNumberOfTaps: numberOfTaps,
                   numberOfTouches: numberOfTouches)
    }

    func press(forDuration duration: TimeInterval) {
        wait().press(forDuration: duration)
    }

    func press(forDuration duration: TimeInterval,
               thenDragTo otherElement: XCUIElement) {
        wait().press(forDuration: duration,
                     thenDragTo: otherElement)
    }

    func swipeUp() {
        wait().swipeUp()
    }

    func swipeDown() {
        wait().swipeDown()
    }

    func swipeLeft() {
        wait().swipeLeft()
    }

    func swipeRight() {
        wait().swipeRight()
    }

    func pinch(withScale scale: CGFloat,
               velocity: CGFloat) {
        wait().pinch(withScale: scale,
                     velocity: velocity)
    }

    func rotate(_ rotation: CGFloat,
                withVelocity velocity: CGFloat) {
        wait().rotate(rotation,
                      withVelocity: velocity)
    }

    func adjust(toNormalizedSliderPosition normalizedSliderPosition: CGFloat) {
        wait().adjust(toNormalizedSliderPosition: normalizedSliderPosition)
    }

    func adjust(toPickerWheelValue pickerWheelValue: String) {
        wait().adjust(toPickerWheelValue: pickerWheelValue)
    }
}
