// @copyright Trollwerks Inc.

import XCTest

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

        let counts = MyProfileVCs.counts.match
        counts.tap()

        snapshot("04ProfileCounts")

        let photos = MyProfileVCs.photos.match
        photos.tap()

        snapshot("05ProfilePhotos")

        let posts = MyProfileVCs.posts.match
        posts.tap()

        snapshot("06ProfilePosts")
    }
}
