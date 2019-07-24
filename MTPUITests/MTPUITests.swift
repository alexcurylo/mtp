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

    func testLoginScreen() {
        launch(settings: [.loggedIn(false)])

        let tabBar = MainTabBar.bar.match
        XCTAssertFalse(tabBar.waitForExistence(timeout: 5))
    }

    func testLocationsTab() {
        launch(settings: [.loggedIn(true)])

        let tabBar = MainTabBar.bar.match
        let locations = MainTabBar.locations.match

        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(locations.isSelected, "locations not selected at startup")
    }

    func testRankingsTab() {
        launch(settings: [.loggedIn(true)])

        let tabBar = MainTabBar.bar.match
        let locations = MainTabBar.locations.match
        let rankings = MainTabBar.rankings.match

        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(locations.isSelected, "locations not selected at startup")

        // note foreseeable failure here:
        // https://openradar.appspot.com/26493495
        rankings.tap()

        let selectedPredicate = NSPredicate(format: "selected == true")
        expectation(for: selectedPredicate, evaluatedWith: rankings, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testProfileTab() {
        launch(settings: [.loggedIn(true)])

        let tabBar = MainTabBar.bar.match
        let locations = MainTabBar.locations.match
        let profile = MainTabBar.profile.match

        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(locations.isSelected, "locations not selected at startup")

        // note foreseeable failure here:
        // https://openradar.appspot.com/26493495
        profile.tap()

        let selectedPredicate = NSPredicate(format: "selected == true")
        expectation(for: selectedPredicate, evaluatedWith: profile, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
}
