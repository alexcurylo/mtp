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

    // swiftlint:disable force_unwrapping

    static var alto: UIColor { // #DBDBDB
        return R.color.alto()!
    }

    static var azureRadiance: UIColor { // #028DFF
        return R.color.azureRadiance()!
    }

    static var carnation: UIColor { // #F5515F
        return R.color.carnation()!
    }

    static var dodgerBlue: UIColor { // #19C0FD
        return R.color.dodgerBlue()!
    }

    static var dustyGray: UIColor { // #9C9C9C
        return R.color.dustyGray()!
    }

    static var facebookButton: UIColor { // #4267B2
        return R.color.facebookButton()!
    }

    static var frenchPass: UIColor { // #D1F1FD
        return R.color.frenchPass()!
    }

    static var gallery: UIColor { // #EEEEEE
        return R.color.gallery()!
    }

    static var mercury: UIColor { // #E9E9E9
        return R.color.mercury()!
    }

    static var pohutukawa: UIColor { // #9F041B
        return R.color.pohutukawa()!
    }

    static var regalBlue: UIColor { // #004B78
        return R.color.regalBlue()!
    }

    static var switchOff: UIColor { // #9B9B9B
        return R.color.switchOff()!
    }

    static var switchOn: UIColor { // #7ED321
        return R.color.switchOn()!
    }

    // swiftlint:enable force_unwrapping
}

extension DispatchTime {

    static var short: DispatchTime {
        return now() + 1
    }

    static var medium: DispatchTime {
        return now() + 4
    }

    static var long: DispatchTime {
        return now() + 8
    }
}

extension UISwitch {

    func styleAsFilter() {
        backgroundColor = .switchOff
        onTintColor = .switchOn
        cornerRadius = 16
    }
}
