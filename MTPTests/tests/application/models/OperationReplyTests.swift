// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class OperationReplyTests: XCTestCase {

    func testDescription() {
        // given
        let sut = OperationReply(code: 200, message: "ok")
        let expected = "code 200: ok"

        // then
        sut.description.assert(equal: expected)
    }
}
