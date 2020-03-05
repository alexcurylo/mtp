// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/18.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

/// AttachmentItem
struct AttachmentItem: FeedbackItemProtocol {

    /// attached
    var attached: Bool { media != .none }
    /// media
    var media: Media?
    /// image
    var image: UIImage? {
        switch media {
        case .image(let img)?: return img
        case .video(let img, _)?: return img
        default: return .none
        }
    }

    /// :nodoc:
    let isHidden: Bool

    /// :nodoc:
    init(isHidden: Bool) { self.isHidden = isHidden }
}
