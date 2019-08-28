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
        launch(settings: [.loggedIn(true),
                          .token("token")])

        UILocations.nearby.tap()

        let thailand = 0
        UINearby.place(thailand).tap()

        // how can we expose callout items?
        //UILocations.close.tap()
        //UILocations.visit.tap()
        //wait(for: 2)

        UILocations.nearby.tap()
        UINearby.place(thailand).doubleTap()

        UILocationPaging.photos.tap()

        UILocationPaging.posts.tap()

        UIPosts.add.tap()

        UIAddPost.post.tap()
        (0...6).forEach { _ in
            UIAddPost.post.type(text: "This is a test post. ")
        }

        UIAddPost.save.tap()

        UILocation.close.tap()

        let gaggan = 3
        UINearby.place(gaggan).doubleTap()

        UILocation.map.tap()

        UILocations.filter.tap()

        UILocationsFilter.close.tap()

        UILocations.search.tap()
        UILocations.search.type(text: "Fred")
        UILocations.result(0).tap()
   }
}
