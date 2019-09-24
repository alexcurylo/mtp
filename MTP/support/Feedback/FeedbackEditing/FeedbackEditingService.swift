// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/09.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

protocol FeedbackEditingEventProtocol {
    func updated(at indexPath: IndexPath)
}

protocol FeedbackEditingServiceProtocol {

    var topics: [TopicProtocol] { get }
    var hasAttachedMedia: Bool { get }

    func update(userEmailText: String?)
    func update(bodyText: String?)
    func update(selectedTopic: TopicProtocol)
    func update(attachmentMedia: Media?)
    func generateFeedback(configuration: FeedbackConfiguration) throws -> Feedback
}

final class FeedbackEditingService {

    var editingItemsRepository: FeedbackEditingItemsRepositoryProtocol
    let feedbackEditingEventHandler: FeedbackEditingEventProtocol

    init(editingItemsRepository: FeedbackEditingItemsRepositoryProtocol,
         feedbackEditingEventHandler: FeedbackEditingEventProtocol) {
        self.editingItemsRepository = editingItemsRepository
        self.feedbackEditingEventHandler = feedbackEditingEventHandler
    }
}

extension FeedbackEditingService: FeedbackEditingServiceProtocol {

    var topics: [TopicProtocol] {
        guard let item = editingItemsRepository.item(of: TopicItem.self) else { return [] }
        return item.topics
    }

    var hasAttachedMedia: Bool {
        guard let item = editingItemsRepository.item(of: AttachmentItem.self) else { return false }
        return item.media != .none
    }

    func update(userEmailText: String?) {
        guard var item = editingItemsRepository.item(of: UserEmailItem.self) else { return }
        item.email = userEmailText
        editingItemsRepository.set(item: item)
    }

    func update(bodyText: String?) {
        guard var item = editingItemsRepository.item(of: BodyItem.self) else { return }
        item.bodyText = bodyText
        editingItemsRepository.set(item: item)
    }

    func update(selectedTopic: TopicProtocol) {
        guard var item = editingItemsRepository.item(of: TopicItem.self) else { return }
        item.selected = selectedTopic
        guard let indexPath = editingItemsRepository.set(item: item) else { return }
        feedbackEditingEventHandler.updated(at: indexPath)
    }

    func update(attachmentMedia: Media?) {
        guard var item = editingItemsRepository.item(of: AttachmentItem.self) else { return }
        item.media = attachmentMedia
        guard let indexPath = editingItemsRepository.set(item: item) else { return }
        feedbackEditingEventHandler.updated(at: indexPath)
    }

    func generateFeedback(configuration: FeedbackConfiguration) throws -> Feedback {
        return try FeedbackGenerator.generate(configuration: configuration,
                                              repository: editingItemsRepository)
    }
}
