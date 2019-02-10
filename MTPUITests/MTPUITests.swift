// @copyright Trollwerks Inc.

// swiftlint:disable line_length
// Travis appears to 100% fail second test with the "Failed to terminate" problem
// Deleting app between each test is an option presented here
// https://stackoverflow.com/questions/33107731/is-there-a-way-to-reset-the-app-between-tests-in-swift-xctest-ui/48715864#48715864

#if FIX_TRAVIS

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
        let third = tabBar.buttons.element(boundBy: 2)

        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(first.isSelected, "first tab not selected at startup")

        // note foreseeable failure here:
        // https://openradar.appspot.com/26493495
        second.tap()

        let selectedPredicate = NSPredicate(format: "selected == true")
        expectation(for: selectedPredicate, evaluatedWith: second, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        third.tap()

        expectation(for: selectedPredicate, evaluatedWith: third, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        first.tap()

        expectation(for: selectedPredicate, evaluatedWith: first, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
}

#endif
