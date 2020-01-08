// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class CountCellItemTests: TestCase {

    func testInitWithCoder() {
        // when
        let sut = CountCellItem(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
