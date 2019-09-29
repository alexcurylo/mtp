// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

/// topic
protocol TopicProtocol {

    /// topicTitle
    var topicTitle: String { get }
}

/// Topic
enum Topic {

    /// feature
    case feature
    /// report
    case report
    /// charles
    case charles
    /// other
    case other

    /// question
    case question
    /// request
    case request
    /// other
    case bugReport
}

extension Topic: TopicProtocol {

    /// topicTitle
    var topicTitle: String {
        switch self {
        case .feature: return L.feedbackFeature()
        case .report: return L.feedbackReport()
        case .charles: return L.feedbackCharles()
        case .other: return L.feedbackOther()

        case .question: return L.feedbackQuestion()
        case .request: return L.feedbackRequest()
        case .bugReport: return L.feedbackBugReport()
        }
    }
}
