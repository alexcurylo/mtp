// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class MyCountsPagingVCTests: XCTestCase {

    func testInitCellWithCoder() {
        // when
        let sut = MyCountsPagingCell(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
