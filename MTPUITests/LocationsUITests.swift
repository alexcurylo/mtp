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

        UIMain.bar.wait()
        UIMain.locations.assert(.selected)
    }
}
