// @copyright Trollwerks Inc.

import UIKit

/// Application navigation, external, and global state functions
protocol ApplicationService {

    /// Launches URL externally
    ///
    /// - Parameter url: URL to launch
    func launch(url: URL)

    /// Route to reveal a Mappable in Locations
    ///
    /// - Parameter mappable: Mappable to reveal
    func route(reveal mappable: Mappable)

    /// Route to show a Mappable in Locations
    ///
    /// - Parameter mappable: Mappable to show
    func route(show mappable: Mappable)

    /// Route to an enumerated destination
    ///
    /// - Parameter route: Route case
    func route(to route: Route)

    /// End any editing in application
    func endEditing()

    /// Dismiss any presented controllers
    func dismissPresentations()
}

/// Enumerated routing destinations
enum Route {

    /// Locations tab
    case locations
    /// Rankings tab
    case rankings
    /// My Profile tab
    case myProfile
    /// Edit Profile presentation in My Profile
    case editProfile
    /// MFMailComposer from Contact Us in Settings in My Profile
    case reportContent(String)

    /// Tab to select for a route
    var tabIndex: Int {
        switch self {
        case .locations: return 0
        case .rankings: return 1
        case .myProfile,
             .editProfile,
             .reportContent: return 2
        }
    }
}

extension UIApplication: ApplicationService {

    /// Launches URL externally
    ///
    /// - Parameter url: URL to launch
    func launch(url: URL) {
        open(url, options: [:], completionHandler: nil)
    }

    /// Route to reveal a Mappable in Locations
    ///
    /// - Parameter mappable: Mappable to reveal
    func route(reveal mappable: Mappable) {
        MainTBC.route(reveal: mappable)
    }

    /// Route to show a Mappable in Locations
    ///
    /// - Parameter mappable: Mappable to show
    func route(show mappable: Mappable) {
        MainTBC.route(show: mappable)
    }

    /// Route to an enumerated destination
    ///
    /// - Parameter route: Route case
    func route(to route: Route) {
        MainTBC.route(to: route)
    }

    /// End any editing in application
    func endEditing() {
        UIApplication.shared.sendAction(
            #selector(UIApplication.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil)
    }

    /// Dismiss any presented controllers
    func dismissPresentations() {
        MainTBC.dismissPresentations()
    }
}
