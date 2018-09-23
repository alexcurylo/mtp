// @copyright Trollwerks Inc.

import UIKit

let style = Styler.self

enum Styler {
    case login
    case map
    case standard

    func styleAppearance() {
        styleAppearanceNavBar()
        styleAppearanceSearchBar()
    }

    func styleAppearanceNavBar() {
        UINavigationBar.styleAppearance(transparency: .transparent,
                                        tint: barTint,
                                        color: barColor,
                                        font: barFont)
    }

    func styleAppearanceSearchBar() {
        UISearchBar.styleAppearance()
     }

    var barTint: UIColor {
        switch self {
        case .login: return .azureRadiance
        case .map: return .azureRadiance
        case .standard: return .white
        }
    }

    var barColor: UIColor {
        switch self {
        case .login: return .regalBlue
        case .map: return .azureRadiance
        case .standard: return .white
        }
    }

    var barFont: UIFont {
        switch self {
        case .login: return Avenir.heavy.of(size: 18)
        case .map: return Avenir.heavy.of(size: 18)
        case .standard: return Avenir.black.of(size: 18)
        }
    }
}

extension UIColor {

    // http://chir.ag/projects/name-that-color/#FFFFFF

    static var azureRadiance: UIColor { // #028DFF
        return R.color.azureRadiance() ?? .black
    }

    static var carnation: UIColor { // #F5515F
        return R.color.carnation() ?? .black
    }

    static var dodgerBlue: UIColor { // #19C0FD
        return R.color.dodgerBlue() ?? .black
    }

    static var dustyGray: UIColor { // #9C9C9C
        return R.color.dustyGray() ?? .black
    }

    static var facebookButton: UIColor { // #4267B2
        return R.color.facebookButton() ?? .black
    }

    static var frenchPass: UIColor { // #D1F1FD
        return R.color.frenchPass() ?? .black
    }

    static var mercury: UIColor { // #E9E9E9
        return R.color.mercury() ?? .black
    }

    static var pohutukawa: UIColor { // #9F041B
        return R.color.pohutukawa() ?? .black
    }

    static var regalBlue: UIColor { // #004B78
        return R.color.regalBlue() ?? .black
    }
}
