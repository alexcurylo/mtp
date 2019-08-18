// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class ActionHandlerTests: XCTestCase {

    func testUrl() throws {
        // given
        let sut = ActionHandler()
        let url = try unwrap(URL(string: "https://mtp.travel"))

        // when
        let result = sut.application(UIApplication.shared,
                                     open: url,
                                     options: [:])

        // then
        XCTAssertFalse(result)
    }
}
