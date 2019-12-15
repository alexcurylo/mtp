// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class UserCountsPageVCTests: TestCase {

    func testInitWithCoder() {
        // when
        let sut = UserCountsPageVC(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
