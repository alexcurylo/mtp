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

        let tabBar = MainTBCs.bar.match
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "tab bar not found")

        let locations = MainTBCs.locations.match
        XCTAssertTrue(locations.isSelected, "first tab not selected at startup")

        snapshot("01Locations")

        let nearby = LocationsVCs.nearby.match
        nearby.tap()

        //snapshot("02LocationsNearby")

        let rankings = MainTBCs.rankings.match
        rankings.tap()

        let selectedPredicate = NSPredicate(format: "selected == true")
        expectation(for: selectedPredicate, evaluatedWith: rankings, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        snapshot("02Rankings")

        //app.scrollViews.otherElements.collectionViews.cells.buttons["Visited: 847"].tap()

        //snapshot("04RankingsProfile")

        let myProfile = MainTBCs.myProfile.match
        myProfile.tap()

        expectation(for: selectedPredicate, evaluatedWith: myProfile, handler: nil)
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
