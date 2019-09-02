// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class RankingsPagingVCTests: XCTestCase {

    func testInitCellWithCoder() {
        // when
        let sut = RankingPagingCell(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
