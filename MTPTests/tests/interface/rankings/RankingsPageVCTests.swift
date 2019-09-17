// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class RankingsPageVCTests: MTPTestCase {

    func testInitWithCoder() {
        // when
        let sut = RankingsPageVC(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
