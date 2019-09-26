// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class SystemVersionCellTests: XCTestCase {

    func testConfigure() {
        let cell = SystemVersionCell(style: .default,
                                     reuseIdentifier: SystemVersionCell.reuseIdentifier)
        let item = SystemVersionItem()
        let indexPath = IndexPath(row: 0, section: 0)
        SystemVersionCell.configure(cell, with: item, for: indexPath, eventHandler: .none)
        XCTAssertEqual(cell.textLabel?.text, "iOS")
        XCTAssertEqual(cell.detailTextLabel?.text, item.version)
    }
}
