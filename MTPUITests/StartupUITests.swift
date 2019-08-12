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

        UILogin.forgot.tap()

        UILoginFail.message.assert(.label("That does not appear to be a valid email!"))
        UILoginFail.ok.tap()

        UILogin.email.tap()
        UILogin.email.type(text: "test@test.com")
        UILogin.forgot.tap()
    }

    func testSignup() {
        launch(settings: [.loggedIn(false)])

        UIRoot.signup.tap()
    }
}
