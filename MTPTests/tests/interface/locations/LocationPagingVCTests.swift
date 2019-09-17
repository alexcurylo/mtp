// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class LocationPagingVCTests: MTPTestCase {

    func testInitWithCoder() {
        // when
        let sut = LocationPagingVC(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
