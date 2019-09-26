// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class AppBuildCellTests: XCTestCase {

    func testConfigure() {
        let cell = AppBuildCell(style: .value1, reuseIdentifier: AppBuildCell.reuseIdentifier)
        let item = AppBuildItem(isHidden: false)
        AppBuildCell.configure(cell,
                               with: item,
                               for: IndexPath(row: 0, section: 0),
                               eventHandler: .none)
        XCTAssertEqual(cell.textLabel?.text, "Build")
    }
}
