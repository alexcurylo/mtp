// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class FeedbackItemsDataSourceTests: XCTestCase {

    func testNumberOfSections() {
        let dataSource = FeedbackItemsDataSource(topics: TopicItem.defaultTopics,
                                                 hidesUserEmailCell: true,
                                                 hidesAttachmentCell: false,
                                                 hidesAppInfoSection: true)
        XCTAssertEqual(dataSource.numberOfSections, 3)
    }

    func testSection() {
        let dataSource = FeedbackItemsDataSource(topics: TopicItem.defaultTopics,
                                                 hidesUserEmailCell: false,
                                                 hidesAttachmentCell: false,
                                                 hidesAppInfoSection: true)
        XCTAssertEqual(dataSource.section(at: 0).title, "User Detail")
    }

    func testItem() {
        let dataSource = FeedbackItemsDataSource(topics: TopicItem.defaultTopics,
                                                 hidesUserEmailCell: true,
                                                 hidesAttachmentCell: false,
                                                 hidesAppInfoSection: true)
        let item: TopicItem? = dataSource.item(of: TopicItem.self)
        XCTAssertNotNil(item)
    }

    func testSetItem() throws {
        let dataSource = FeedbackItemsDataSource(topics: TopicItem.defaultTopics,
                                                 hidesUserEmailCell: true,
                                                 hidesAttachmentCell: false,
                                                 hidesAppInfoSection: true)
        var item = try XCTUnwrap(dataSource.item(of: BodyItem.self))
        item.bodyText = "body"
        let indexPath: IndexPath? = dataSource.set(item: item)
        XCTAssertNotNil(indexPath)
    }
}
