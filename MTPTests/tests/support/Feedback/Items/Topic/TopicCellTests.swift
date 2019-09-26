// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class TopicCellTests: XCTestCase {

    func testConfigure() {
        let cell = TopicCell(style: .default, reuseIdentifier: TopicCell.reuseIdentifier)
        let item = TopicItem(TopicItem.defaultTopics)
        let indexPath = IndexPath(row: 0, section: 0)
        TopicCell.configure(cell, with: item, for: indexPath, eventHandler: .none)
        XCTAssertEqual(cell.textLabel?.text, "Topic")
        XCTAssertEqual(cell.detailTextLabel?.text, item.selected?.localizedTitle)
    }
}
