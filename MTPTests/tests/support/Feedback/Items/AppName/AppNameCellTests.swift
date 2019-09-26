// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class AppNameCellTests: XCTestCase {

    func testConfigure() {
        let cell = AppNameCell(style: .value1, reuseIdentifier: AppNameCell.reuseIdentifier)
        let item = AppNameItem(isHidden: false)
        AppNameCell.configure(cell,
                              with: item,
                              for: IndexPath(row: 0, section: 0),
                              eventHandler: .none)
        XCTAssertEqual(cell.textLabel?.text, "Name")
    }
}
