// @copyright Trollwerks Inc.

import KRProgressHUD

let style = Styler.self

enum Styler {
    case login
    case map
    case standard

    func styleAppearance() {
        styleAppearanceNavBar()
        styleAppearanceSearchBar()
        styleAppearanceProgress()
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

    func styleAppearanceProgress() {
        KRProgressHUD.set(maskType: .custom(color: UIColor(white: 0, alpha: 0.8)))
        KRProgressHUD.set(style: .black)
        KRProgressHUD.set(activityIndicatorViewColors: [.white, UIColor(white: 0.7, alpha: 1)])
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

    // swiftlint:enable force_unwrapping
}
