// @copyright Trollwerks Inc.

import UIKit

/// Enumerated font provider
enum Avenir: String, ServiceProvider {

    /// Avenir-Light
    case light = "Avenir-Light"
    /// Avenir-LightOblique
    case lightOblique = "Avenir-LightOblique"
    /// Avenir-Book
    case book = "Avenir-Book"
    /// Avenir-BookOblique
    case bookOblique = "Avenir-BookOblique"
    /// Avenir-Roman
    case roman = "Avenir-Roman"
    /// Avenir-Oblique
    case oblique = "Avenir-Oblique"
    /// Avenir-Medium
    case medium = "Avenir-Medium"
    /// Avenir-MediumOblique
    case mediumOblique = "Avenir-MediumOblique"
    /// Avenir-Heavy
    case heavy = "Avenir-Heavy"
    /// Avenir-HeavyOblique
    case heavyOblique = "Avenir-HeavyOblique"
    /// Avenir-Black
    case black = "Avenir-Black"
    /// Avenir-BlackOblique
    case blackOblique = "Avenir-BlackOblique"

    /// Font provider
    ///
    /// - Parameter size: Points
    /// - Returns: Font
    func of(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: self.rawValue, size: size) else {
            log.debug("Missing font: \(self.rawValue) \(size)")
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
}

extension UISearchBar {

    /// Apply default styled appearance
    static func styleAppearance() {
        let proxy = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        proxy.font = Avenir.book.of(size: 15)
    }

    /// Find search text field inside self
    var searchField: UITextField? {
        return value(forKey: "searchField") as? UITextField
    }

    /// Remove searchField's clear butotn
    func removeClearButton() {
        searchField?.clearButtonMode = .never
    }
}
