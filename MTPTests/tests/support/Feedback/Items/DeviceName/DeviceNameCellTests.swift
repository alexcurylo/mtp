// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class DeviceNameCellTests: XCTestCase {

    func testConfigure() {
        let cell = DeviceNameCell(style: .default,
                                  reuseIdentifier: DeviceNameCell.reuseIdentifier)
        let item = DeviceNameItem()
        let indexPath = IndexPath(row: 0, section: 0)
        DeviceNameCell.configure(cell, with: item, for: indexPath, eventHandler: .none)
        XCTAssertEqual(cell.textLabel?.text, "Device")
        XCTAssertEqual(cell.detailTextLabel?.text, "Simulator")
    }
}
