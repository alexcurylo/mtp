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

        UILogin.close.tap()

        UIRoot.login.tap()

        UILogin.signup.tap()

        UISignup.login.tap()

        UILogin.forgot.tap()

        UILoginFail.message.assert(.label("That does not appear to be a valid email!"))
        UILoginFail.ok.tap()

        UILogin.email.tap()
        UILogin.email.type(text: "test@test.com")
        UILogin.forgot.tap()

        UIForgotPassword.cancel.tap()

        UILogin.forgot.tap()

        UIForgotPassword.send.tap()

        UILogin.login.tap()

        UILoginFail.message.assert(.label("Please enter a password!"))
        UILoginFail.ok.tap()

        UILogin.toggle.tap()
        UILogin.toggle.tap()
        UILogin.password.tap()
        UILogin.password.type(text: "password")
        UILogin.login.tap()
    }

    // swiftlint:disable:next function_body_length
    func testSignupEmail() {
        launch(settings: [.loggedIn(false)])

        UIRoot.signup.tap()

        UISignup.close.tap()

        UIRoot.signup.tap()

        UISignup.login.tap()

        UILogin.signup.tap()

        UISignup.credentials.swipeUp()
        UISignup.signup.tap()

        UISignupFail.message.assert(.label("Please agree to the MTP Terms Of Use!"))
        UISignupFail.ok.tap()

        UISignup.tos.tap()

        UITerms.agree.tap()

        UISignup.signup.tap()

        UISignupFail.message.assert(.label("That does not appear to be a valid email!"))
        UISignupFail.ok.tap()

        UISignup.email.tap()
        UISignup.email.type(text: "test@test.com")
        UISignup.signup.tap()

        UISignupFail.message.assert(.label("Please enter a first name!"))
        UISignupFail.ok.tap()

        UISignup.first.tap()
        UISignup.first.type(text: "First")
        UISignup.signup.tap()

        UISignupFail.message.assert(.label("Please enter a last name!"))
        UISignupFail.ok.tap()

        UISignup.last.tap()
        UISignup.last.type(text: "Last")
        UISignup.signup.tap()

        UISignupFail.message.assert(.label("Please enter a password of at least 6 characters!"))
        UISignupFail.ok.tap()

        UISignup.togglePassword.tap()
        UISignup.togglePassword.tap()
        UISignup.password.tap()
        UISignup.password.type(text: "password")
        UISignup.signup.tap()

        UISignupFail.message.assert(.label("Those passwords do not match!"))
        UISignupFail.ok.tap()

        UISignup.toggleConfirm.tap()
        UISignup.toggleConfirm.tap()
        UISignup.confirm.tap()
        UISignup.confirm.type(text: "password")
        UISignup.signup.tap()

        UIWelcome.later.tap()

        // Turn off checkRemindedVerify() guard
        // and send reminder notice here

        UIMain.myProfile.tap()

        UIMyProfile.settings.tap()

        UISettings.delete.tap()

        UIConfirmDelete.cancel.tap()

        UISettings.delete.tap()

        UIConfirmDelete.confirm.tap()

        UIRoot.signup.wait()
    }

    func testSignupFacebook() {
        launch(settings: [.loggedIn(false)])

        UIRoot.signup.tap()

        UISignup.facebook.tap()

        UISignupFail.message.assert(.label("Failed to get information from Facebook!"))
        UISignupFail.ok.tap()

        UISignup.credentials.swipeUp()
        UISignup.tos.tap()

        UITerms.agree.tap()

        UISignup.email.tap()
        UISignup.email.type(text: "test@test.com")

        UIKeyboard.next.tap()

        UISignup.first.type(text: "First")

        UISignup.last.tap()
        UISignup.last.type(text: "Last")

        UISignup.birthday.tap()

        UIKeyboard.clear.tap()

        UISignup.confirm.tap()
        UISignup.confirm.type(text: "password")

        UIKeyboard.back.tap()

        UISignup.password.type(text: "password")

        UIKeyboard.done.tap()

        UIWelcome.profile.tap()

        UIEditProfile.close.tap()

        UIMyProfile.settings.tap()

        UISettings.logout.tap()

        UIRoot.signup.wait()
    }
}
