// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class RankingHeaderTests: TestCase {

    func testInitWithCoder() {
        // when
        let sut = RankingHeader(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
