// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class PostPayloadTests: TestCase {

    func testDescription() {
        // given
        let sut = PostPayload()

        // then
        sut.description.assert(equal: "post for 0: ")
    }
}
