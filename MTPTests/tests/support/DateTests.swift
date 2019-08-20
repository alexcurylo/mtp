// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class DateTests: XCTestCase {

    func testFutureString() {
        // given
        let past = Date().addingTimeInterval(600)

        // when
        let result = past.toStringWithRelativeTime()

        // then
        result.assert(equal: "in 10 minutes")
    }
}
