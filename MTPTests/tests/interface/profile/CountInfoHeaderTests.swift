// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class CountInfoHeaderTests: MTPTestCase {

    func testInitWithCoder() {
        // when
        let sut = CountInfoHeader(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
