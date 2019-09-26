// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class AppVersionCellTests: XCTestCase {

    func testConfigure() {
        let cell = AppVersionCell(style: .value1, reuseIdentifier: AppVersionCell.reuseIdentifier)
        let item = AppVersionItem(isHidden: false)
        AppVersionCell.configure(cell,
                                 with: item,
                                 for: IndexPath(row: 0, section: 0),
                                 eventHandler: .none)
        XCTAssertEqual(cell.textLabel?.text, "Version")
    }
}
