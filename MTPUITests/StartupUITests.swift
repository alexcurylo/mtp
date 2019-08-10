// @copyright Trollwerks Inc.

import XCTest

final class StartupUITests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLogin() {
        launch(settings: [.loggedIn(false)])

        UIRoot.login.tap()
    }

    func testSignup() {
        launch(settings: [.loggedIn(false)])

        UIRoot.signup.tap()
    }
}
