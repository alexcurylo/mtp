// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class RankingsPagingVCTests: MTPTestCase {

    func testInitCellWithCoder() {
        // when
        let sut = RankingPagingCell(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
