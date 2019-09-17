// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class PostPayloadTests: MTPTestCase {

    func testDescription() {
        // given
        let sut = PostPayload(post: "text",
                              location: LocationPayload(),
                              location_id: 0,
                              status: "A")

        // then
        sut.description.assert(equal: "post for 0: text")
    }
}
