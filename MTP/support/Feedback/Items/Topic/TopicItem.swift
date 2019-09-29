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
        return [Topic.feature,
                Topic.report,
                Topic.charles,
                Topic.other]
    }

    /// topicTitle
    var topicTitle: String {
        return selected?.topicTitle ?? topics.first?.topicTitle ?? ""
    }
    /// topics
    var topics: [TopicProtocol] = []
    /// selected
    var selected: TopicProtocol? {
        get { return _selected ?? topics.first }
        set { _selected = newValue }
    }
    private var _selected: TopicProtocol?

    /// :nodoc:
    let isHidden: Bool

    /// :nodoc:
    init(topics list: [TopicProtocol],
         selected topic: TopicProtocol? = nil) {
        topics = list
        _selected = topic
        isHidden = topics.isEmpty
    }
}
