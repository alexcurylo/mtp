// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class CountCellItemTests: MTPTestCase {

    func testInitWithCoder() {
        // when
        let sut = CountCellItem(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
