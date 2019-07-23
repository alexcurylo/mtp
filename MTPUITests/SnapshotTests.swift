// @copyright Trollwerks Inc.

import XCTest

// Travis appears to haveissues with the "Failed to terminate" problem
// Deleting app between each test is an option presented here
// swiftlint:disable:next line_length
// https://stackoverflow.com/questions/33107731/is-there-a-way-to-reset-the-app-between-tests-in-swift-xctest-ui/48715864#48715864

final class SnapshotTests: XCTestCase {

    private let app = XCUIApplication()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_snapshot_Tabs() {
        launch(arguments: [.takingScreenshots],
               settings: [.loggedIn(true)])

        let tabBar = app.tabBars.element(boundBy: 0)
        let first = tabBar.buttons.element(boundBy: 0)
        let second = tabBar.buttons.element(boundBy: 1)
        let third = tabBar.buttons.element(boundBy: 2)

        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(first.isSelected, "first tab not selected at startup")

        snapshot("01Locations")

        //app.navigationBars["MTP.LocationsVC"].buttons["navListBlue"].tap()

        //snapshot("02LocationsNearby")

        // note foreseeable failure here:
        // https://openradar.appspot.com/26493495
        //let tabBarsQuery = app.tabBars
        //tabBarsQuery.buttons["Rankings"].tap()
        second.tap()

        let selectedPredicate = NSPredicate(format: "selected == true")
        expectation(for: selectedPredicate, evaluatedWith: second, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        snapshot("02Rankings")

        //app.scrollViews.otherElements.collectionViews.cells.buttons["Visited: 847"].tap()

        //snapshot("04RankingsProfile")

        third.tap()
        //tabBarsQuery.buttons["My Profile"].tap()

        expectation(for: selectedPredicate, evaluatedWith: third, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        snapshot("03ProfileAbout")

        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.cells.staticTexts["Counts"].tap()

        snapshot("04ProfileCounts")
        collectionViewsQuery.cells.staticTexts["Photos"].tap()

        snapshot("05ProfilePhotos")

        collectionViewsQuery.cells.staticTexts["Posts"].tap()

        snapshot("06ProfilePosts")
    }
}
