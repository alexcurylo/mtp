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

    func apply() {
        styleAppearanceNavBar()
    }

    func styleAppearanceNavBar() {
        switch self {
        case .login:
            UINavigationBar.styleAppearance(transparency: .transparent,
                                            tint: .azureRadiance,
                                            color: .regalBlue,
                                            font: Avenir.heavy.of(size: 18))
        case .map:
            UINavigationBar.styleAppearance(transparency: .transparent,
                                            tint: .azureRadiance,
                                            color: .azureRadiance,
                                            font: Avenir.heavy.of(size: 18))
        case .standard:
            UINavigationBar.styleAppearance(transparency: .transparent,
                                            tint: .white,
                                            color: .white,
                                            font: Avenir.black.of(size: 18))
        }
    }

    func styleAppearanceSearchBar() {
        UISearchBar.styleAppearance()
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
