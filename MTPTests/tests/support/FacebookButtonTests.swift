// @copyright Trollwerks Inc.

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

    func testLogout() {
        // when
        FacebookButton.logOut()

        // then
        XCTAssertNil(FacebookButton.current)
    }
}
