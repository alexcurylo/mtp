// @copyright Trollwerks Inc.

import UIKit

/// Application navigation, external, and global state functions
protocol ApplicationService {

    /// Launches URL externally
    /// - Parameter url: URL to launch
    func launch(url: URL)

    /// Route to reveal a Mappable in Locations
    /// - Parameter mappable: Mappable to reveal
    func route(reveal mappable: Mappable)

    /// Route to show a Mappable in Locations
    /// - Parameter mappable: Mappable to show
    func route(show mappable: Mappable)

    /// Route to an enumerated destination
    /// - Parameter route: Route case
    func route(to route: Route)

    /// End any editing in application
    func endEditing()

    /// Dismiss any presented controllers
    func dismissPresentations()

    /// Application version(build) string
    var version: String { get }
}

/// Enumerated tabs
enum Tab: Int {

    /// Locations tab
    case locations
    /// Rankings tab
    case rankings
    /// My Profile tab
    case myProfile
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
    /// Network Status in Settings in My Profile
    case network
    /// Contact Us in Settings in My Profile
    case reportContent(String)

    /// Tab to select for a route
    var tabIndex: Int {
        switch self {
        case .locations: return Tab.locations.rawValue
        case .rankings: return Tab.rankings.rawValue
        case .myProfile,
             .editProfile,
             .network,
             .reportContent: return Tab.myProfile.rawValue
        }
    }
}

extension UIApplication: ApplicationService {

    /// Launches URL externally
    /// - Parameter url: URL to launch
    func launch(url: URL) {
        open(url, options: [:], completionHandler: nil)
    }

    /// Route to reveal a Mappable in Locations
    /// - Parameter mappable: Mappable to reveal
    func route(reveal mappable: Mappable) {
        MainTBC.route(reveal: mappable)
    }

    /// Route to show a Mappable in Locations
    /// - Parameter mappable: Mappable to show
    func route(show mappable: Mappable) {
        MainTBC.route(show: mappable)
    }

    /// Route to an enumerated destination
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

    /// Application version(build) string
    var version: String {
        var header = ""
        if let app = StringKey.appVersion.string,
           let build = StringKey.appBuild.string {
            header = L.appVersion(app, build)
        }
        return header
    }
}
