// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

final class FeedbackConfiguration {

    var subject: String?
    var additionalDiagnosticContent: String?
    var toRecipients: [String]
    var ccRecipients: [String]
    var bccRecipients: [String]
    var usesHTML: Bool
    var dataSource: FeedbackItemsDataSource

    /*
    If topics array contains no topics, topics cell is hidden.
    */
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
