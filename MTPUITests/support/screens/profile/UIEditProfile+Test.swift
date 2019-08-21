// @copyright Trollwerks Inc.

import XCTest

extension UIEditProfile: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .avatar,
             .close,
             .linkAdd,
             .linkDelete,
             .save:
            return .button
        case .airport,
             .birthday,
             .country,
             .email,
             .first,
             .gender,
             .last,
             .linkTitle,
             .linkUrl,
             .location:
            return .textField
        case .about:
            return .textView
        }
    }
}
