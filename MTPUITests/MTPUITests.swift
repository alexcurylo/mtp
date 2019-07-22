// @copyright Trollwerks Inc.

import XCTest

// Travis appears to haveissues with the "Failed to terminate" problem
// Deleting app between each test is an option presented here
// swiftlint:disable:next line_length
// https://stackoverflow.com/questions/33107731/is-there-a-way-to-reset-the-app-between-tests-in-swift-xctest-ui/48715864#48715864

final class MTPUITests: XCTestCase {

    private let app = XCUIApplication()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_snapshot_01LoginScreen() {
        launch(arguments: [.takingScreenshots],
               settings: [.loggedIn(false)])

        let tabBar = app.tabBars.element(boundBy: 0)
        XCTAssertFalse(tabBar.waitForExistence(timeout: 5))

        snapshot("01LoginScreen")
    }

    func test_snapshot_02LocationsTab() {
        launch(arguments: [.takingScreenshots],
               settings: [.loggedIn(true)])

        let tabBar = app.tabBars.element(boundBy: 0)
        let first = tabBar.buttons.element(boundBy: 0)
        //let second = tabBar.buttons.element(boundBy: 1)
        //let third = tabBar.buttons.element(boundBy: 2)

        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(first.isSelected, "first tab not selected at startup")

        snapshot("02LocationsTab")
    }

    func test_snapshot_03RankingsTab() {
        launch(arguments: [.takingScreenshots],
               settings: [.loggedIn(true)])

        let tabBar = app.tabBars.element(boundBy: 0)
        let first = tabBar.buttons.element(boundBy: 0)
        let second = tabBar.buttons.element(boundBy: 1)
        //let third = tabBar.buttons.element(boundBy: 2)

        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(first.isSelected, "first tab not selected at startup")

        // note foreseeable failure here:
        // https://openradar.appspot.com/26493495
        second.tap()

        let selectedPredicate = NSPredicate(format: "selected == true")
        expectation(for: selectedPredicate, evaluatedWith: second, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        snapshot("03RankingsTab")
    }

    func test_snapshot_04ProfileTab() {
        launch(arguments: [.takingScreenshots],
               settings: [.loggedIn(true)])

        let tabBar = app.tabBars.element(boundBy: 0)
        let first = tabBar.buttons.element(boundBy: 0)
        //let second = tabBar.buttons.element(boundBy: 1)
        let third = tabBar.buttons.element(boundBy: 2)

        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(first.isSelected, "first tab not selected at startup")

        // note foreseeable failure here:
        // https://openradar.appspot.com/26493495
        third.tap()

        let selectedPredicate = NSPredicate(format: "selected == true")
        expectation(for: selectedPredicate, evaluatedWith: third, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        snapshot("04ProfileTab")
    }
}
