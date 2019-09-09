// @copyright Trollwerks Inc.

import XCTest

extension UISettings: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .about,
             .close,
             .contact,
             .delete,
             .faq,
             .logout,
             .network,
             .review,
             .share:
            return .button
        }
    }
}
