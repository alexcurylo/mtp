// @copyright Trollwerks Inc.

import UIKit

let style = Styler.self

enum Styler {
    case login
    case map
    case standard

    func apply() {
        switch self {
        case .login:
            UINavigationBar.set(transparency: .transparent,
                                tint: .azureRadiance,
                                color: .regalBlue,
                                font: Avenir.heavy.of(size: 18))
        case .map:
            UINavigationBar.set(transparency: .transparent,
                                tint: .azureRadiance,
                                color: .azureRadiance,
                                font: Avenir.heavy.of(size: 18))
        case .standard:
            UINavigationBar.set(transparency: .transparent,
                                color: .white,
                                font: Avenir.black.of(size: 18))
        }
    }
}

extension UIColor {

    // http://chir.ag/projects/name-that-color/#FFFFFF

    class var azureRadiance: UIColor { // #028DFF
        return R.color.azureRadiance() ?? .black
    }

    class var carnation: UIColor { // #F5515F
        return R.color.carnation() ?? .black
    }

    class var dodgerBlue: UIColor { // #19C0FD
        return R.color.dodgerBlue() ?? .black
    }

    class var dustyGray: UIColor { // #9C9C9C
        return R.color.dustyGray() ?? .black
    }

    class var facebookButton: UIColor { // #4267B2
        return R.color.facebookButton() ?? .black
    }

    class var frenchPass: UIColor { // #D1F1FD
        return R.color.frenchPass() ?? .black
    }

    class var mercury: UIColor { // #E9E9E9
        return R.color.mercury() ?? .black
    }

    class var pohutukawa: UIColor { // #9F041B
        return R.color.pohutukawa() ?? .black
    }

    class var regalBlue: UIColor { // #004B78
        return R.color.regalBlue() ?? .black
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
