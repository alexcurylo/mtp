// @copyright Trollwerks Inc.

import UIKit

enum Transparency {
    case transparent
    case translucent
    case opaque
}

extension UINavigationBar {

    static func set(transparency: Transparency? = nil,
                    tint: UIColor? = nil,
                    color: UIColor? = nil,
                    font: UIFont? = nil) {
        let global = appearance()

        global.tintColor = tint ?? color
        var attributes = [NSAttributedStringKey: Any]()
        attributes[.foregroundColor] = color
        attributes[.font] = font
        global.titleTextAttributes = attributes

        switch transparency {
        case .transparent?:
            global.setBackgroundImage(UIImage(), for: .default)
            global.shadowImage = UIImage()
            global.isTranslucent = true
        case .translucent?:
            global.setBackgroundImage(nil, for: .default)
            global.shadowImage = nil
            global.isTranslucent = true
        case .opaque?:
            global.setBackgroundImage(nil, for: .default)
            global.shadowImage = nil
            global.isTranslucent = false
        case .none:
            break
        }
    }
}
