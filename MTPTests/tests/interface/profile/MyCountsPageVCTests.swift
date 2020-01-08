// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class MyCountsPageVCTests: TestCase {

    func testInitWithCoder() {
        // when
        let sut = MyCountsPageVC(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
