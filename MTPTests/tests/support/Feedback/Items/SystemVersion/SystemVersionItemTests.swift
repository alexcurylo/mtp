// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class SystemVersionItemTests: XCTestCase {

    func testVersion() {
        let item = SystemVersionItem()
        XCTAssertEqual(item.version, UIDevice.current.systemVersion)
    }
}
