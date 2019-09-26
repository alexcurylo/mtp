// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

/// title
protocol TopicProtocol {

    /// title
    var title: String { get }
    /// localizedTitle
    var localizedTitle: String { get }
}

/// Topic
enum Topic: String {

        /// question
    case question = "Question"
        /// request
    case request = "Request"
        /// other
    case bugReport = "Bug Report"
        /// other
    case other = "Other"
}

extension Topic: TopicProtocol {

    /// localizedTitle
    var title: String { return rawValue }
    /// localizedTitle
    var localizedTitle: String {
        switch self {
        case .question: return L.feedbackQuestion()
        case .request: return L.feedbackRequest()
        case .bugReport: return L.feedbackBugReport()
        case .other: return L.feedbackOther()
        }
    }
}
