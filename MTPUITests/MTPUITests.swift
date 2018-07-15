// @copyright Trollwerks Inc.

import XCTest

final class MTPUITests: XCTestCase {

    private let app = XCUIApplication()

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFirstLaunch() {
        launch(settings: [.loggedIn(false)])

        let tabBar = app.tabBars.element(boundBy: 0)
        XCTAssertFalse(tabBar.waitForExistence(timeout: 5))
    }

    func testTabNavigation() {
        launch(settings: [.loggedIn(true)])

        let tabBar = app.tabBars.element(boundBy: 0)
        let first = tabBar.buttons.element(boundBy: 0)
        let second = tabBar.buttons.element(boundBy: 1)

        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
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
