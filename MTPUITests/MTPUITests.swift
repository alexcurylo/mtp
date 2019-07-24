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

    func testLogin() {
        launch(settings: [.loggedIn(false)])

        let tabBar = MainTBCs.bar.match
        XCTAssertFalse(tabBar.waitForExistence(timeout: 5), "tab bar not found")

        //app.printList(of: .button)
        //app.printHierarchy()
    }

    func testLocations() {
        launch(settings: [.loggedIn(true)])

        let tabBar = MainTBCs.bar.match
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "tab bar not found")

        let locations = MainTBCs.locations.match
        XCTAssertTrue(locations.isSelected, "locations not selected at startup")
    }

    func testRankings() {
        launch(settings: [.loggedIn(true)])

        let tabBar = MainTBCs.bar.match
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "tab bar not found")

        let locations = MainTBCs.locations.match
        XCTAssertTrue(locations.isSelected, "locations not selected at startup")

        // note foreseeable failure here:
        // https://openradar.appspot.com/26493495
        let rankings = MainTBCs.rankings.match
        rankings.tap()

        let selectedPredicate = NSPredicate(format: "selected == true")
        expectation(for: selectedPredicate, evaluatedWith: rankings, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testMyProfile() {
        launch(settings: [.loggedIn(true)])

        let tabBar = MainTBCs.bar.match
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "tab bar not found")

        let locations = MainTBCs.locations.match
        XCTAssertTrue(locations.isSelected, "locations not selected at startup")

        let myProfile = MainTBCs.myProfile.match
        myProfile.tap()

        let selectedPredicate = NSPredicate(format: "selected == true")
        expectation(for: selectedPredicate, evaluatedWith: myProfile, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
}
