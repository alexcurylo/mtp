// @copyright Trollwerks Inc.

import XCTest

final class LocationsUITests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLocations() {
        launch(settings: [.loggedIn(true)])

        UILocations.nearby.tap()

        let thailand = 0
        UINearby.place(thailand).doubleTap()

        UILocationPaging.photos.tap()

        UILocationPaging.posts.tap()

        UILocation.close.tap()

        let gaggan = 3
        UINearby.place(gaggan).doubleTap()

        UILocation.map.tap()

        UILocations.filter.tap()

        UILocationsFilter.close.tap()
    }
}