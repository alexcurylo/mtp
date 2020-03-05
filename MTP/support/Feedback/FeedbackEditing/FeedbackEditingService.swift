// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/09.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

/// FeedbackEditingEventProtocol
protocol FeedbackEditingEventProtocol {

    /// Upate notification
    /// - Parameter indexPath: Path updated
    func updated(at indexPath: IndexPath)
}

/// FeedbackEditingServiceProtocol
protocol FeedbackEditingServiceProtocol {

    /// topics
    var topics: [TopicProtocol] { get }
    /// hasAttachedMedia
    var hasAttachedMedia: Bool { get }

    /// Upate email
    /// - Parameter userEmailText: Email address
    func update(userEmailText: String?)
    /// Upate phone
    /// - Parameter userPhoneText: Phone
    func update(userPhoneText: String?)
    /// Update body
    /// - Parameter bodyText: Text
    func update(bodyText: String?)
    /// Update topic
    /// - Parameter selectedTopic: Topic
    func update(selectedTopic: TopicProtocol)
    /// Update attachment
    /// - Parameter attachmentMedia: Media
    func update(attachmentMedia: Media?)
    /// Generate feedback
    /// - Parameter configuration: configuration
    func generateFeedback(configuration: FeedbackConfiguration) throws -> Feedback
}

/// FeedbackEditingService
final class FeedbackEditingService {

    private var editingItemsRepository: FeedbackEditingItemsRepositoryProtocol
    private let feedbackEditingEventHandler: FeedbackEditingEventProtocol

    /// :nodoc:
    init(editingItemsRepository: FeedbackEditingItemsRepositoryProtocol,
         feedbackEditingEventHandler: FeedbackEditingEventProtocol) {
        self.editingItemsRepository = editingItemsRepository
        self.feedbackEditingEventHandler = feedbackEditingEventHandler
    }
}

extension FeedbackEditingService: FeedbackEditingServiceProtocol {

    /// topics
    var topics: [TopicProtocol] {
        guard let item = editingItemsRepository.item(of: TopicItem.self) else { return [] }
        return item.topics
    }

    /// hasAttachedMedia
    var hasAttachedMedia: Bool {
        guard let item = editingItemsRepository.item(of: AttachmentItem.self) else { return false }
        return item.media != .none
    }

    /// Upate email
    /// - Parameter userEmailText: Email address
    func update(userEmailText: String?) {
        guard var item = editingItemsRepository.item(of: UserEmailItem.self) else { return }
        item.email = userEmailText
        editingItemsRepository.set(item: item)
    }

    /// Upate phone
    /// - Parameter userPhoneText: Phone
    func update(userPhoneText: String?) {
        guard var item = editingItemsRepository.item(of: UserPhoneItem.self) else { return }
        item.phone = userPhoneText
        editingItemsRepository.set(item: item)
    }

    /// Update body
    /// - Parameter bodyText: Text
    func update(bodyText: String?) {
        guard var item = editingItemsRepository.item(of: BodyItem.self) else { return }
        item.bodyText = bodyText
        editingItemsRepository.set(item: item)
    }

    /// Update topic
    /// - Parameter selectedTopic: Topic
    func update(selectedTopic: TopicProtocol) {
        guard var item = editingItemsRepository.item(of: TopicItem.self) else { return }
        item.selected = selectedTopic
        guard let indexPath = editingItemsRepository.set(item: item) else { return }
        feedbackEditingEventHandler.updated(at: indexPath)
    }

    /// Update attachment
    /// - Parameter attachmentMedia: Media
func update(attachmentMedia: Media?) {
        guard var item = editingItemsRepository.item(of: AttachmentItem.self) else { return }
        item.media = attachmentMedia
        guard let indexPath = editingItemsRepository.set(item: item) else { return }
        feedbackEditingEventHandler.updated(at: indexPath)
    }

    /// Generate feedback
    /// - Parameter configuration: configuration
    func generateFeedback(configuration: FeedbackConfiguration) throws -> Feedback {
        try FeedbackGenerator.generate(configuration: configuration,
                                       repository: editingItemsRepository)
    }
}
