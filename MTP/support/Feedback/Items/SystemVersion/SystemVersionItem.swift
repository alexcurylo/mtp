// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/24.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

/// SystemVersionItem
struct SystemVersionItem: FeedbackItemProtocol {

    /// version
    var version: String { UIDevice.current.systemVersion }

    /// :nodoc:
    let isHidden: Bool = false
}
