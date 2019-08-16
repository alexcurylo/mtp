// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class ProfilePagingVCTests: XCTestCase {

    func testInitWithCoder() {
        // when
        let sut = ProfilePagingVC(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
