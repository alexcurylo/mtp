// @copyright Trollwerks Inc.

import UIKit

let style = Styler.self

enum Styler {
    case standard
    case login

    func apply() {
        switch self {
        case .standard:
            UINavigationBar.set(transparency: .transparent,
                                color: .white,
                                font: Avenir.black.of(size: 18))
        case .login:
            UINavigationBar.set(transparency: .transparent,
                                tint: .azureRadiance,
                                color: .regalBlue,
                                font: Avenir.heavy.of(size: 18))
        }
    }
}

extension UIColor {

    // http://chir.ag/projects/name-that-color/#D1F1FD

    class var azureRadiance: UIColor { // #028DFF
        return UIColor(named: R.color.azureRadiance.name) ?? .black
    }

    class var frenchPass: UIColor { // #D1F1FD
        return UIColor(named: R.color.frenchPass.name) ?? .black
    }

    class var regalBlue: UIColor { // #004B78
        return UIColor(named: R.color.regalBlue.name) ?? .black
    }
}

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
