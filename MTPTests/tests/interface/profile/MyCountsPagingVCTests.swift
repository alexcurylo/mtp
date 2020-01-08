// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class MyCountsPagingVCTests: TestCase {

    func testInitCellWithCoder() {
        // when
        let sut = MyCountsPagingCell(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
