// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/22.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

enum Media: Equatable {

    var jpegData: Data? {
        guard case let .image(image) = self else { return .none }
        return image.jpegData(compressionQuality: 0.5)
    }
    var videoData: Data? {
        guard case let .video(_, url) = self else { return .none }
        return try? Data(contentsOf: url)
    }

    case image(UIImage)
    case video(UIImage, URL)

    static func == (lhs: Media, rhs: Media) -> Bool {
        switch (lhs, rhs) {
        case let (.image(lImage), .image(rImage)):
            return lImage == rImage
        case let (.video(_, lUrl), .video(_, rUrl)):
            return lUrl == rUrl
        default:
            return false
        }
    }
}
