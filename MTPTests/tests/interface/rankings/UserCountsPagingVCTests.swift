// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class UserCountsPagingVCTests: XCTestCase {

    func testInitWithCoder() {
        // when
        let sut = UserCountsPagingVC(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }
}
