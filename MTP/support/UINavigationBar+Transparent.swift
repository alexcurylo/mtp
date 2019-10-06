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
        UINavigationBar.style(bar: self,
                              transparency: style.transparency,
                              titleFont: style.titleFont,
                              titleColor: style.titleColor,
                              itemColor: style.itemColor,
                              barColor: style.barColor)
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
                                barColor: UIColor? = nil) {
        let proxy = UINavigationBar.appearance()
        UINavigationBar.style(bar: proxy,
                              transparency: transparency,
                              titleFont: titleFont,
                              titleColor: titleColor,
                              itemColor: itemColor,
                              barColor: barColor)
    }

    private static func style(bar: UINavigationBar,
                              transparency: Transparency? = nil,
                              titleFont: UIFont? = nil,
                              titleColor: UIColor? = nil,
                              itemColor: UIColor? = nil,
                              barColor: UIColor? = nil) {
        bar.tintColor = itemColor
        bar.barTintColor = barColor
        let attributes = NSAttributedString.attributes(
            color: titleColor,
            font: titleFont)
        bar.titleTextAttributes = attributes

        switch transparency {
        case .transparent?:
            bar.setBackgroundImage(UIImage(), for: .default)
            bar.shadowImage = UIImage()
            bar.isTranslucent = true
        case .translucent?:
            bar.setBackgroundImage(nil, for: .default)
            bar.shadowImage = nil
            bar.isTranslucent = true
        case .opaque?:
            bar.setBackgroundImage(nil, for: .default)
            bar.shadowImage = nil
            bar.isTranslucent = false
        case .none:
            break
        }
    }
}
