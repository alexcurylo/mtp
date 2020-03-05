// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/25.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

/// Feedback
struct Feedback {

    /// email
    let email: String?
    /// to
    let to: [String]
    /// cc
    let cc: [String] // swiftlint:disable:this identifier_name
    /// bcc
    let bcc: [String]
    /// subject
    let subject: String
    /// body
    let body: String
    /// isHTML
    let isHTML: Bool
    /// jpeg
    let jpeg: Data?
    /// mp4
    let mp4: Data?
    /// phone
    let phone: String?
}
