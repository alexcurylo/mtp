// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class TopicItemTests: XCTestCase {

    func testSelected() {
        var item = TopicItem(topics: [])
        let topics = TopicItem.defaultTopics

        XCTAssertNil(item.selected)

        item.topics = topics
        XCTAssertEqual(item.selected?.topicTitle, topics.first?.topicTitle)

        item.selected = topics[1]
        XCTAssertEqual(item.selected?.topicTitle, topics[1].topicTitle)
    }
}
