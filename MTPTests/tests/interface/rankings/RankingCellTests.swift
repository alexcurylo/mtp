// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class RankingCellTests: TestCase {

    func testInitWithCoder() {
        // when
        let sut = RankingCell(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
