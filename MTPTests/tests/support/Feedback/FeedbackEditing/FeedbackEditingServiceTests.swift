// @copyright Trollwerks Inc.

//
//  FeedbackEditingServiceTests.swift
//  CTFeedbackSwift
//
//  Created by 和泉田 領一 on 2017/09/17.
//  Copyright © 2017 CAPH TECH. All rights reserved.
//

@testable import MTP
import XCTest

final class FeedbackEditingServiceTests: XCTestCase {

    private var itemsRepository: MockFeedbackEditingItemsRepository?
    private var eventHandler: MockFeedbackEditingEventHandler?
    private var service: FeedbackEditingService?

    override func setUp() {
        super.setUp()

        let itemsRepository = MockFeedbackEditingItemsRepository()
        self.itemsRepository = itemsRepository
        let eventHandler = MockFeedbackEditingEventHandler()
        self.eventHandler = eventHandler
        service = FeedbackEditingService(editingItemsRepository: itemsRepository,
                                         feedbackEditingEventHandler: eventHandler)
    }

    override func tearDown() {
        itemsRepository = nil
        eventHandler = nil
        service = nil

        super.tearDown()
    }

    func testTopics() throws {
        try XCTUnwrap(itemsRepository).set(item: TopicItem(topics: TopicItem.defaultTopics))
        let topics = try XCTUnwrap(service).topics
        XCTAssertEqual(topics.count, 4)
    }

    func testHasAttachedMediaWithNoMedia() throws {
        let item = AttachmentItem(isHidden: false)
        try XCTUnwrap(itemsRepository).set(item: item)
        XCTAssertFalse(try XCTUnwrap(service).hasAttachedMedia)
    }

    func testHasAttachedMediaWithImage() throws {
        var item = AttachmentItem(isHidden: false)
        item.media = .image(UIImage())
        try XCTUnwrap(itemsRepository).set(item: item)
        XCTAssertTrue(try XCTUnwrap(service).hasAttachedMedia)
    }

    func testUpdateUserEmailText() throws {
        try XCTUnwrap(itemsRepository).set(item: UserEmailItem(isHidden: false))
        XCTAssertNil(try XCTUnwrap(itemsRepository).item(of: UserEmailItem.self)?.email)
        try XCTUnwrap(service).update(userEmailText: "test")
        XCTAssertEqual(try XCTUnwrap(itemsRepository).item(of: UserEmailItem.self)?.email, "test")
    }

    func testUpdateBodyText() throws {
        try XCTUnwrap(itemsRepository).set(item: BodyItem(bodyText: .none))
        XCTAssertNil(try XCTUnwrap(itemsRepository).item(of: BodyItem.self)?.bodyText)
        try XCTUnwrap(service).update(bodyText: "test")
        XCTAssertEqual(try XCTUnwrap(itemsRepository).item(of: BodyItem.self)?.bodyText, "test")
    }

    func testUpdateSelectedTopic() throws {
        try XCTUnwrap(itemsRepository).set(item: TopicItem(topics: TopicItem.defaultTopics))
        XCTAssertNil(try XCTUnwrap(eventHandler).invokedUpdatedParameters)
        try XCTUnwrap(service).update(selectedTopic: TopicItem.defaultTopics[1])
        XCTAssertEqual(try XCTUnwrap(eventHandler).invokedUpdatedParameters?.indexPath,
                       IndexPath(row: 0, section: 0))
    }

    func testUpdateAttachmentMedia() throws {
        try XCTUnwrap(itemsRepository).set(item: AttachmentItem(isHidden: false))
        try XCTUnwrap(service).update(attachmentMedia: .image(UIImage()))
        XCTAssertEqual(try XCTUnwrap(eventHandler).invokedUpdatedParameters?.indexPath,
                       IndexPath(row: 0, section: 0))
    }

    func testGenerateFeedback() throws {
        let dataSource = FeedbackItemsDataSource(topics: TopicItem.defaultTopics)
        service = FeedbackEditingService(editingItemsRepository: dataSource,
                                         feedbackEditingEventHandler: try XCTUnwrap(eventHandler))
        let configuration = FeedbackConfiguration(subject: "String",
                                                  topics: TopicItem.defaultTopics,
                                                  additionalDiagnosticContent: "additional",
                                                  toRecipients: ["test@example.com"],
                                                  ccRecipients: ["cc@example.com"],
                                                  bccRecipients: ["bcc@example.com"])
        let feedback = try XCTUnwrap(service).generateFeedback(configuration: configuration)
        XCTAssertEqual(feedback.subject, "String")
        XCTAssertEqual(feedback.to, ["test@example.com"])
        XCTAssertEqual(feedback.cc, ["cc@example.com"])
        XCTAssertEqual(feedback.bcc, ["bcc@example.com"])
        XCTAssertFalse(feedback.isHTML)
    }
}

private class MockFeedbackEditingItemsRepository: FeedbackEditingItemsRepositoryProtocol {

    var stubbedItems: [Any] = []

    func item<Item>(of type: Item.Type) -> Item? {
        return stubbedItems.first { item in item is Item } as? Item
    }

    @discardableResult
    func set<Item>(item: Item) -> IndexPath? {
        if let index = stubbedItems.firstIndex(where: { stored in stored is Item }) {
            stubbedItems.remove(at: index)
        }
        stubbedItems.append(item)
        return IndexPath(row: 0, section: 0)
    }
}

private class MockFeedbackEditingEventHandler: FeedbackEditingEventProtocol {

    var invokedUpdated = false
    var invokedUpdatedCount = 0
    var invokedUpdatedParameters: (indexPath: IndexPath, Void)?
    var invokedUpdatedParametersList = [(indexPath: IndexPath, Void)]()

    func updated(at indexPath: IndexPath) {
        invokedUpdated = true
        invokedUpdatedCount += 1
        invokedUpdatedParameters = (indexPath, ())
        invokedUpdatedParametersList.append((indexPath, ()))
    }
}
