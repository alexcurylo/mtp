// @copyright Trollwerks Inc.

import UIKit

enum Avenir: String {
    case light = "Avenir-Light"
    case lightOblique = "Avenir-LightOblique"
    case book = "Avenir-Book"
    case bookOblique = "Avenir-BookOblique"
    case roman = "Avenir-Roman"
    case oblique = "Avenir-Oblique"
    case medium = "Avenir-Medium"
    case mediumOblique = "Avenir-MediumOblique"
    case heavy = "Avenir-Heavy"
    case heavyOblique = "Avenir-HeavyOblique"
    case black = "Avenir-Black"
    case blackOblique = "Avenir-BlackOblique"

    func of(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: self.rawValue, size: size) else {
            log.debug("Missing font: \(self.rawValue) \(size)")
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
}

extension UISearchBar {

    static func styleAppearance() {
        let proxy = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        proxy.font = Avenir.book.of(size: 15)
    }
}
