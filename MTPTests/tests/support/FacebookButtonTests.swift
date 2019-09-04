// @copyright Trollwerks Inc.

import FacebookCore
import FacebookLogin
import FBSDKLoginKit
@testable import MTP
import XCTest

final class FacebookButtonTests: XCTestCase {

    private var sut: FacebookButton?

    override func setUp() {
        super.setUp()

        sut = FacebookButton()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func testLoginCancel() {
        // given
        let mock = FBLoginManagerMock(result: .cancelled)

        // when
        var completed = false
        sut?.login(vc: UIViewController(), mock: mock) { _ in
            completed = true
        }

        // then
        XCTAssertTrue(completed)
    }

    func testLoginFail() {
        // given
        let mock = FBLoginManagerMock(result: .failed("error"))

        // when
        var completed = false
        sut?.login(vc: UIViewController(), mock: mock) { _ in
            completed = true
        }

        // then
        XCTAssertTrue(completed)
    }

    func testLoginSuccess() {
        // given
        let token = AccessToken(tokenString: "token",
                                permissions: [],
                                declinedPermissions: [],
                                expiredPermissions: [],
                                appID: "app",
                                userID: "id",
                                expirationDate: nil,
                                refreshDate: nil,
                                dataAccessExpirationDate: nil)
        let mock = FBLoginManagerMock(result: .success(granted: [], declined: [], token: token))

        // when
        var completed = false
        sut?.login(vc: UIViewController(), mock: mock) { _ in
            completed = true
        }

        // then
        XCTAssertTrue(completed)
    }

    func testLogout() {
        // when
        FacebookWrapper.logOut()

        // then
        XCTAssertNil(FacebookWrapper.token)
    }
}

private struct FBLoginManagerMock: FacebookLoginManager {

    let result: LoginResult

    func logIn(permissions: [Permission],
               viewController: UIViewController?,
               completion: LoginResultBlock?) {
        completion?(result)
    }
}
