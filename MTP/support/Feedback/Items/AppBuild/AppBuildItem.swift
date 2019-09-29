// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/24.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import Foundation

/// AppBuildItem
struct AppBuildItem: FeedbackItemProtocol {

    /// buildString
    var buildString: String {
        guard let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
            else { return "" }
        return build
    }

    /// :nodoc:
    let isHidden: Bool

    /// :nodoc:
    init(isHidden: Bool) { self.isHidden = isHidden }
}
