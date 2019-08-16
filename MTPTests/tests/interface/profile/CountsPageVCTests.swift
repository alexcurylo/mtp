// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class CountsPageVCTests: XCTestCase {

    func testInitWithCoder() {
        // when
        let sut = CountsPageVC(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
