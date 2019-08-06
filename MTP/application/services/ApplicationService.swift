// @copyright Trollwerks Inc.

import UIKit

protocol ApplicationService {

    func launch(url: URL)

    /// Route to display a Mappable in Locations
    ///
    /// - Parameter mappable: Mappable to display
    func route(to mappable: Mappable)
    /// Route to display a User in Locations
    ///
    /// - Parameter user: User to display
    func route(to user: User?)
    /// Route to an enumerated destination
    ///
    /// - Parameter route: Route case
    func route(to route: Route)

    func endEditing()
}

/// Enumerated routing destinations
enum Route: Int {

    /// Locations tab
    case locations = 0
    /// Rankings tab
    case rankings = 1
    /// My Profile tab
    case myProfile = 2
    /// Edit Profile presentation in My Profile
    case editProfile
}

extension UIApplication: ApplicationService {

    func launch(url: URL) {
        open(url, options: [:], completionHandler: nil)
    }

    /// Route to display a Mappable in Locations
    ///
    /// - Parameter mappable: Mappable to display
    func route(to mappable: Mappable) {
        MainTBC.route(to: mappable)
    }

    /// Route to display a User in Locations
    ///
    /// - Parameter user: User to display
    func route(to user: User?) {
        MainTBC.route(to: user)
    }

    /// Route to an enumerated destination
    ///
    /// - Parameter route: Route case
    func route(to route: Route) {
        MainTBC.route(to: route)
    }

    func endEditing() {
        UIApplication.shared.sendAction(
            #selector(UIApplication.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil)
    }
}
