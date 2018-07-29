// @copyright Trollwerks Inc.

import UIKit

enum Transparency {
    case transparent
    case translucent
    case opaque
}

extension UINavigationBar {

    static func set(transparency: Transparency,
                    color: UIColor? = .white,
                    font: UIFont? = UIFont(name: "Avenir-Black", size: 18)) {
        let global = appearance()

        global.tintColor = color
        var attributes = [NSAttributedStringKey: Any]()
        attributes[.foregroundColor] = color
        attributes[.font] = font
        global.titleTextAttributes = attributes

        switch transparency {
        case .transparent:
            global.setBackgroundImage(UIImage(), for: .default)
            global.shadowImage = UIImage()
            global.isTranslucent = true
        case .translucent:
            global.setBackgroundImage(nil, for: .default)
            global.shadowImage = nil
            global.isTranslucent = true
        case .opaque:
            global.setBackgroundImage(nil, for: .default)
            global.shadowImage = nil
            global.isTranslucent = false
        }
    }
}
