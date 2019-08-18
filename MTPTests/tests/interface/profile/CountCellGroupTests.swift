// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class CountCellGroupTests: XCTestCase {

    func testInitWithCoder() {
        // when
        let sut = CountCellGroup(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
