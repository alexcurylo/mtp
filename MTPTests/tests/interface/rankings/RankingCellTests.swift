// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class RankingCellTests: XCTestCase {

    func testInitWithCoder() {
        // when
        let sut = RankingCell(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
