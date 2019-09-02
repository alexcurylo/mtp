// @copyright Trollwerks Inc.

import XCTest

extension UIPhotos: Elemental {

    var type: XCUIElement.ElementType {
        switch self {
        case .add,
             .save:
            return .button
        case .photos:
            return .collectionView
        case .photo:
            return .cell
        }
    }
}
