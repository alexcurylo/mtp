// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class ActionHandlerTests: TestCase {

    func testUrl() throws {
        // given
        let sut = ActionHandler()
        let url = try XCTUnwrap(URL(string: "https://mtp.travel"))

        // when
        let result = sut.application(UIApplication.shared,
                                     open: url,
                                     options: [:])

        // then
        XCTAssertFalse(result)
    }
}
