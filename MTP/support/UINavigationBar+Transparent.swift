// @copyright Trollwerks Inc.

import UIKit

/// Transparency valyes, particularly of navigation bars
enum Transparency {

    /// Transparent
    case transparent
    /// Translucent
    case translucent
    /// Opaque
    case opaque
}

extension UIViewController {

    /// Hide navigation bar
    ///
    /// - Parameter animated: Whether to animate
    func hide(navBar animated: Bool) {
        if let presenter = presentingViewController {
            presenter.hide(navBar: animated)
        } else if let nav = navigationController {
            nav.setNavigationBarHidden(true, animated: animated)
        }
    }

    /// Hide tool bar
    ///
    /// - Parameter animated: Whether to animate
    func hide(toolBar animated: Bool) {
        if let presenter = presentingViewController {
            presenter.hide(toolBar: animated)
        } else if let nav = navigationController {
            nav.setToolbarHidden(true, animated: animated)
        }
    }

    /// Show navigation bar
    ///
    /// - Parameter animated: Whether to animate
    func show(navBar animated: Bool, style: Styler? = nil) {
        if let style = style {
            navigationController?.navigationBar.set(style: style)
        }
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    /// Show tool bar
    ///
    /// - Parameter animated: Whether to animate
    func show(toolBar animated: Bool) {
        navigationController?.setToolbarHidden(false, animated: animated)
    }
}

extension UINavigationBar {

    /// Set predefined style
    ///
    /// - Parameter style: Style definition
    func set(style: Styler) {
        tintColor = style.itemColor
        let attributes = NSAttributedString.attributes(
            color: style.titleColor,
            font: style.titleFont)
        titleTextAttributes = attributes
    }

    /// Style appearance of navigation bar
    ///
    /// - Parameters:
    ///   - transparency: Transparency
    ///   - titleFont: Title font
    ///   - titleColor: Title color
    ///   - itemColor: Item color
    ///   - backgroundColor: Background color
    static func styleAppearance(transparency: Transparency? = nil,
                                titleFont: UIFont? = nil,
                                titleColor: UIColor? = nil,
                                itemColor: UIColor? = nil,
                                backgroundColor: UIColor? = nil) {
        let proxy = UINavigationBar.appearance()

        proxy.tintColor = itemColor
        proxy.barTintColor = backgroundColor
        let attributes = NSAttributedString.attributes(color: titleColor,
                                                       font: titleFont)
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
