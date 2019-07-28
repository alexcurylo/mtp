// @copyright Trollwerks Inc.

import XCTest

final class SnapshotTests: XCTestCase {

    // to reset all simulators:
    // xcrun simctl shutdown all
    // xcrun simctl erase all

    private let app = XCUIApplication()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // swiftlint:disable:next function_body_length
    func test_Snapshots() {
        launch(arguments: [.takingScreenshots],
               settings: [.loggedIn(true)])

        let tabBar = MainTBCs.bar.match
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "tab bar not found")

        let locations = MainTBCs.locations.match
        XCTAssertTrue(locations.isSelected, "first tab not selected at startup")

        snapshot("01Locations")

        let nearby = LocationsVCs.nearby.match
        nearby.tap()

        snapshot("02Nearby")

        let place = NearbyVCs.place(2).match
        place.tap()

        snapshot("03Callout")

        nearby.tap()
        place.doubleTap()

        snapshot("04Info")

        let rankings = MainTBCs.rankings.match
        rankings.tap()

        let selectedPredicate = NSPredicate(format: "selected == true")
        expectation(for: selectedPredicate, evaluatedWith: rankings, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        snapshot("05Rankings")

        let userProfile = RankingVCs.profile(.locations, 2).match
        userProfile.tap()

        snapshot("06UserProfile")

        let close = UserProfileVCs.close.match
        close.tap()

        let filter = RankingVCs.filter.match
        filter.tap()

        snapshot("07Filter")

        let myProfile = MainTBCs.myProfile.match
        myProfile.tap()

        expectation(for: selectedPredicate, evaluatedWith: myProfile, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        let counts = MyProfileVCs.counts.match
        counts.tap()

        snapshot("08MyCounts")

        let photos = MyProfileVCs.photos.match
        photos.tap()

        snapshot("09MyPhotos")

        let posts = MyProfileVCs.posts.match
        posts.tap()

        snapshot("10MyPosts")
    }
}
