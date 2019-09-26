// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class DeviceNameItemTests: XCTestCase {

    func testDeviceName() {
        let item = DeviceNameItem()
        XCTAssertEqual(item.deviceName, "Simulator")
    }
}
