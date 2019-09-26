// @copyright Trollwerks Inc.

import XCTest

final class AppStoreSnapshotTests: XCTestCase {

    // to reset all simulators:
    // xcrun simctl shutdown all
    // xcrun simctl erase all

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAppStoreSnapshots() {
        launch(arguments: [.takingScreenshots],
               settings: [.loggedIn(true)])

        UIMain.locations.assert(.selected)

        snapshot("01Locations")

        UILocations.nearby.tap()

        snapshot("02Nearby")

        let gaggan = 3
        UINearby.place(gaggan).tap()

        snapshot("03Callout")

        UILocations.nearby.tap()
        let thailand = 0
        UINearby.place(thailand).doubleTap()

        snapshot("04Info")

        UIMain.rankings.tap()
        UIMain.rankings.wait(for: .selected)

        snapshot("05Rankings")

        let charles = 2
        UIRankingsPage.profile(.locations, charles).tap()

        wait(for: 5)
        snapshot("06UserProfile")

        UIUserProfile.close.tap()

        UIRankings.filter.tap()

        snapshot("07Filter")

        UIMain.myProfile.tap()

        UIProfilePaging.counts.tap()

        snapshot("08MyCounts")

        UIProfilePaging.photos.tap()

        wait(for: 8)
        snapshot("09MyPhotos")

        UIProfilePaging.posts.tap()

        snapshot("10MyPosts")
    }
}
