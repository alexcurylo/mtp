// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class NotificationsHandlerTests: XCTestCase {

    func testUpdateToken() throws {
        // given
        let sut = NotificationsHandler()
        let token = "4159c48ab8466e4450b1de594c6df3a0879dc6e754b7faa4ae43467336178a4f"
        let data = try unwrap(token.data(using: String.Encoding.utf8))

        // when
        sut.application(UIApplication.shared,
                        didRegisterForRemoteNotificationsWithDeviceToken: data)

        // then
        let spy = try unwrap(sut.net as? NetworkServiceSpy)
        XCTAssertTrue(spy.invokedUserUpdateToken)
    }
}
