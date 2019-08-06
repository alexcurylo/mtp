// @copyright Trollwerks Inc.

import UIKit

/// Service wrapper for a Styler type instance
protocol StyleService {

    var styler: Styler.Type { get }
}

extension StyleService {

    /// Service instance simply returns Styler type
    var styler: Styler.Type { return Styler.self }
}

/// No actual implementation needed for StyleService adoptees
struct StyleServiceImpl: StyleService { }

/// Type encapsulating various styles to apply
enum Styler {

    /// Login and Signup
    case login
    /// Locations tab
    case map
    /// Anywhere else in app
    case standard
    /// Plain system appearance
    case system

    /// Set up default appearances
    func styleAppearance() {
        styleAppearanceNavBar()
        styleAppearanceSearchBar()
    }

    /// Set up nav bar default appearance
    func styleAppearanceNavBar() {
        UINavigationBar.styleAppearance(transparency: .transparent,
                                        titleFont: titleFont,
                                        titleColor: titleColor,
                                        itemColor: itemColor,
                                        backgroundColor: nil)
    }

    /// Set up search bar default appearance
    func styleAppearanceSearchBar() {
        UISearchBar.styleAppearance()
     }

    /// Item color accessor
    var itemColor: UIColor {
        switch self {
        case .login: return .azureRadiance
        case .map: return .azureRadiance
        case .standard: return .white
        case .system: return .azureRadiance
        }
    }

    /// Title color accessor
    var titleColor: UIColor {
        switch self {
        case .login: return .regalBlue
        case .map: return .azureRadiance
        case .standard: return .white
        case .system: return .black
       }
    }

    /// Title font accessor
    var titleFont: UIFont {
        switch self {
        case .login: return Avenir.heavy.of(size: 18)
        case .map: return Avenir.heavy.of(size: 18)
        case .standard: return Avenir.black.of(size: 18)
        case .system: return Avenir.medium.of(size: 18)
       }
    }
}

extension UIColor {

    // http://chir.ag/projects/name-that-color/#FFFFFF

    // swiftlint:disable force_unwrapping

    /// Color of alto
    static var alto: UIColor { // #DBDBDB
        return R.color.alto()!
    }

    /// Color of azureRadiance
    static var azureRadiance: UIColor { // #028DFF
        return R.color.azureRadiance()!
    }

    /// Color of carnation
    static var carnation: UIColor { // #F5515F
        return R.color.carnation()!
    }

    /// Color of dodgerBlue
    static var dodgerBlue: UIColor { // #19C0FD
        return R.color.dodgerBlue()!
    }

    /// Color of dustyGray
    static var dustyGray: UIColor { // #9C9C9C
        return R.color.dustyGray()!
    }

    /// Color of facebookButton
    static var facebookButton: UIColor { // #4267B2
        return R.color.facebookButton()!
    }

    /// Color of frenchPass
    static var frenchPass: UIColor { // #D1F1FD
        return R.color.frenchPass()!
    }

    /// Color of gallery
    static var gallery: UIColor { // #EEEEEE
        return R.color.gallery()!
    }

    /// Color of mercury
    static var mercury: UIColor { // #E9E9E9
        return R.color.mercury()!
    }

    /// Color of pohutukawa
    static var pohutukawa: UIColor { // #9F041B
        return R.color.pohutukawa()!
    }

    /// Color of regalBlue
    static var regalBlue: UIColor { // #004B78
        return R.color.regalBlue()!
    }

    /// Color of switchOff
    static var switchOff: UIColor { // #9B9B9B
        return R.color.switchOff()!
    }

    /// Color of switchOn
    static var switchOn: UIColor { // #7ED321
        return R.color.switchOn()!
    }

    /// Color of visited markers
    static var visited: UIColor { // #08B815
        return R.color.visited()!
    }

    // swiftlint:enable force_unwrapping
}

extension DispatchTime {

    /// 0.25 second
    static var veryShort: DispatchTime {
        return now() + 0.25
    }

    /// 1 second
    static var short: DispatchTime {
        return now() + 1
    }

    /// 4 seconds
    static var medium: DispatchTime {
        return now() + 4
    }

    /// 8 seconds
    static var long: DispatchTime {
        return now() + 8
    }
}

extension UISwitch {

    /// Switch style for filter pages
    func styleAsFilter() {
        backgroundColor = .switchOff
        onTintColor = .switchOn
        cornerRadius = 16
    }
}
