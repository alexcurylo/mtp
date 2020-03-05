// @copyright Trollwerks Inc.

import XCTest

protocol Elemental: Exposable {

    var container: XCUIElementQuery { get }
    var element: XCUIElement { get }
    var type: XCUIElement.ElementType { get }
}

enum ElementalState {

    case exists
    case hittable
    case label(String)
    case selected
}

extension Elemental {

    var all: XCUIElementQuery {
        type.all
    }

    var container: XCUIElementQuery {
        all
    }

    var element: XCUIElement {
        identified
    }

    var identified: XCUIElement {
        container.element(matching: type, identifier: identifier)
    }

    var match: XCUIElement {
        element.firstMatch
    }

    var exists: Bool {
        match.exists
    }

    var isHittable: Bool {
        match.isHittable
    }

    var isSelected: Bool {
        match.isSelected
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
        case .label(let text):
            success = matched.label == text
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
        case .label(let text):
            predicate = NSPredicate(format: "label == '\(text)'")
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

    func showMenu() {
        wait().press(forDuration: 1)
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
