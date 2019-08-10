// @copyright Trollwerks Inc.

import XCTest

final class ProfileUITests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testProfile() {
        launch(settings: [.loggedIn(true)])

        UIMain.bar.wait()
        UIMain.locations.assert(.selected)

        UIMain.myProfile.tap()
        UIMain.myProfile.wait(for: .selected)
    }
}
