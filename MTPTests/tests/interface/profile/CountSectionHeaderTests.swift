// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class CountSectionHeaderTests: TestCase {

    func testInitWithCoder() {
        // when
        let sut = CountSectionHeader(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
