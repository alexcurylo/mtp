// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

/// FeedbackConfiguration
final class FeedbackConfiguration {

    /// Subject
    var subject: String?
    /// additionalDiagnosticContent
    var additionalDiagnosticContent: String?
    /// toRecipients
    var toRecipients: [String]
    /// ccRecipients
    var ccRecipients: [String]
    /// bccRecipients
    var bccRecipients: [String]
    /// Uses HTML
    var usesHTML: Bool
    /// Data Source
    var dataSource: FeedbackItemsDataSource

    /// If topics array contains no topics, topics cell is hidden.
    init(subject: String? = .none,
         additionalDiagnosticContent: String? = .none,
         topics: [TopicProtocol] = TopicItem.defaultTopics,
         toRecipients: [String] = [],
         ccRecipients: [String] = [],
         bccRecipients: [String] = [],
         hidesUserEmailCell: Bool = true,
         hidesAttachmentCell: Bool = false,
         hidesAppInfoSection: Bool = false,
         usesHTML: Bool = false) {
        self.subject = subject
        self.additionalDiagnosticContent = additionalDiagnosticContent
        self.toRecipients = toRecipients
        self.ccRecipients = ccRecipients
        self.bccRecipients = bccRecipients
        self.usesHTML = usesHTML
        self.dataSource = FeedbackItemsDataSource(topics: topics,
                                                  hidesUserEmailCell: hidesUserEmailCell,
                                                  hidesAttachmentCell: hidesAttachmentCell,
                                                  hidesAppInfoSection: hidesAppInfoSection)
    }
}
