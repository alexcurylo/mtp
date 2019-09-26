// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

/// TopicItem
struct TopicItem: FeedbackItemProtocol {

    /// defaultTopics
    static var defaultTopics: [TopicProtocol] {
        return [Topic.question,
                Topic.request,
                Topic.bugReport,
                Topic.other]
    }

    /// topicTitle
    var topicTitle: String { return selected?.localizedTitle ?? topics.first?.localizedTitle ?? "" }
    /// topics
    var topics: [TopicProtocol] = []
    /// selected
    var selected: TopicProtocol? {
        get { return _selected ?? topics.first }
        set { _selected = newValue }
    }
    private var _selected: TopicProtocol?

    /// isHidden
    let isHidden: Bool

    /// :nodoc:
    init(_ topics: [TopicProtocol]) {
        self.topics = topics
        self.isHidden = topics.isEmpty
    }
}
