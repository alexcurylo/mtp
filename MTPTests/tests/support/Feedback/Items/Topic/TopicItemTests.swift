// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class TopicItemTests: XCTestCase {

    func testSelected() {
        var item = TopicItem([])
        let topics = TopicItem.defaultTopics

        XCTAssertNil(item.selected)

        item.topics = topics
        XCTAssertEqual(item.selected?.title, topics.first?.title)

        item.selected = topics[1]
        XCTAssertEqual(item.selected?.title, topics[1].title)
    }
}
