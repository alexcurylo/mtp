// @copyright Trollwerks Inc.

import XCTest

final class MTPUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments += [LaunchArgument.uiTestingMode.rawValue]
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testTabNavigation() {
        let app = XCUIApplication()
        let tabBar = app.tabBars.element(boundBy: 0)
        let first = tabBar.buttons.element(boundBy: 0)
        let second = tabBar.buttons.element(boundBy: 1)

        XCTAssertTrue(first.isSelected, "first tab not selected at startup")

        // note foreseeable failure here:
        // https://openradar.appspot.com/26493495
        second.tap()

        let selectedPredicate = NSPredicate(format: "selected == true")
        expectation(for: selectedPredicate, evaluatedWith: second, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        first.tap()

        expectation(for: selectedPredicate, evaluatedWith: first, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
}
