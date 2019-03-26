// @copyright Trollwerks Inc.

import UIKit

enum Transparency {
    case transparent
    case translucent
    case opaque
}

extension UIViewController {

    func hide(navBar animated: Bool) {
        if let presenter = presentingViewController {
            presenter.hide(navBar: animated)
        } else if let nav = navigationController {
            nav.setNavigationBarHidden(true, animated: animated)
        }
    }

    func hide(toolBar animated: Bool) {
        if let presenter = presentingViewController {
            presenter.hide(toolBar: animated)
        } else if let nav = navigationController {
            nav.setToolbarHidden(true, animated: animated)
        }
    }

    func show(navBar animated: Bool, style: Styler? = nil) {
        if let style = style {
            navigationController?.navigationBar.set(style: style)
        }
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func show(toolBar animated: Bool) {
        navigationController?.setToolbarHidden(false, animated: animated)
    }
}

extension UINavigationBar {

    func set(style: Styler) {
        tintColor = style.barTint
        let attributes = NSAttributedString.attributes(
            color: style.barColor,
            font: style.barFont)
        titleTextAttributes = attributes
    }

    static func styleAppearance(transparency: Transparency? = nil,
                                tint: UIColor? = nil,
                                color: UIColor? = nil,
                                font: UIFont? = nil) {
        let proxy = UINavigationBar.appearance()

        proxy.tintColor = tint ?? color
        let attributes = NSAttributedString.attributes(color: color,
                                                       font: font)
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
