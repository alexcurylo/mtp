// @copyright Trollwerks Inc.

import UIKit

enum Transparency {
    case transparent
    case translucent
    case opaque
}

extension UINavigationBar {

    static func styleAppearance(transparency: Transparency? = nil,
                                tint: UIColor? = nil,
                                color: UIColor? = nil,
                                font: UIFont? = nil) {
        let proxy = UINavigationBar.appearance()

        proxy.tintColor = tint ?? color
        var attributes = [NSAttributedStringKey: Any]()
        attributes[.foregroundColor] = color
        attributes[.font] = font
        proxy.titleTextAttributes = attributes

        switch transparency {
        case .transparent?:
            proxy.setBackgroundImage(UIImage(), for: .default)
            proxy.shadowImage = UIImage()
            proxy.isTranslucent = true
        case .translucent?:
            proxy.setBackgroundImage(nil, for: .default)
            proxy.shadowImage = nil
            proxy.isTranslucent = true
        case .opaque?:
            proxy.setBackgroundImage(nil, for: .default)
            proxy.shadowImage = nil
            proxy.isTranslucent = false
        case .none:
            break
        }
    }
}
