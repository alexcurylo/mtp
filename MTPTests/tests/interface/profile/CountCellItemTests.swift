// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class CountCellItemTests: XCTestCase {

    func testInitWithCoder() {
        // when
        let sut = CountCellItem(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
