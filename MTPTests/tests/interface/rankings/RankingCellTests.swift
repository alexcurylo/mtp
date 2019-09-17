// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class RankingCellTests: MTPTestCase {

    func testInitWithCoder() {
        // when
        let sut = RankingCell(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
