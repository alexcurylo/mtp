// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class RankingsPageVCTests: TestCase {

    func testInitWithCoder() {
        // when
        let sut = RankingsPageVC(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
