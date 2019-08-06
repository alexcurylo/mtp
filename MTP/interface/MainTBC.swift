// @copyright Trollwerks Inc.

import UIKit

/// Root view for logged in user
final class MainTBC: UITabBarController, ServiceProvider {

    private typealias Segues = R.segue.myProfileVC

    private var destination: Route?

    private static var current: MainTBC?

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        MainTBC.current = self
        checkDestination()
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hide(navBar: animated)
        checkDestination()
        expose()
    }

    /// Actions to take after reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkDestination()
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }

    /// Route to display a Mappable in Locations
    ///
    /// - Parameter mappable: Mappable to display
    static func route(to mappable: Mappable) {
        guard let current = MainTBC.current else { return }

        current.dismiss(presentations: current)
        current.locations?.reveal(mappable: mappable, callout: true)
        current.selectedIndex = Route.locations.rawValue
    }

    /// Route to display a User in Locations
    ///
    /// - Parameter user: User to display
    static func route(to user: User?) {
        guard let current = MainTBC.current else { return }

        current.dismiss(presentations: current)
        current.locations?.reveal(user: user)
        current.selectedIndex = Route.locations.rawValue
    }

    /// Route to an enumerated destination
    ///
    /// - Parameter route: Route case
    static func route(to route: Route) {
        guard let current = MainTBC.current else { return }

        current.dismiss(presentations: current)
        current.destination = route
        current.checkDestination()
    }
}

// MARK: - Private

private extension MainTBC {

    var locations: LocationsVC? {
        let nav = viewControllers?[Route.locations.rawValue] as? UINavigationController
        return nav?.topViewController as? LocationsVC
    }

    var rankings: RankingsVC? {
        let nav = viewControllers?[Route.rankings.rawValue] as? UINavigationController
        return nav?.topViewController as? RankingsVC
    }

    var myProfile: MyProfileVC? {
        let nav = viewControllers?[Route.myProfile.rawValue] as? UINavigationController
        return nav?.topViewController as? MyProfileVC
    }

    func checkDestination() {
        guard let goto = destination else { return }

        switch goto {
        case .locations, .rankings, .myProfile:
            selectedIndex = goto.rawValue
        case .editProfile:
            selectedIndex = Route.myProfile.rawValue
            myProfile?.performSegue(withIdentifier: Segues.directEdit, sender: self)
        }

        destination = nil
    }
}

// MARK: - Exposing

extension MainTBC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        MainTBCs.bar.expose(item: tabBar)
        var buttons = [
            MainTBCs.locations,
            MainTBCs.rankings,
            MainTBCs.myProfile
        ]
        for control in tabBar.subviews where control is UIControl {
            control.expose(as: buttons.first)
            guard buttons.count > 1 else { return }
            buttons = Array(buttons.dropFirst())
        }
    }
}

// MARK: - Injectable

extension MainTBC: Injectable {

    /// Injected dependencies
    typealias Model = Route

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        destination = model
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        destination.require()
    }
}

extension UIViewController {

    /// Locate the main tab bar controller
    var mainTBC: MainTBC? {
        if let tbc = tabBarController as? MainTBC {
            return tbc
        } else if let tbc = presentingViewController as? MainTBC {
            return tbc
        } else {
            return presentingViewController?.mainTBC
        }
    }

    /// Dismiss all currently presented controllers
    ///
    /// - Parameter from: View controller to unwind to
    func dismiss(presentations from: UIViewController) {
        if let presented = from.presentedViewController {
            dismiss(presentations: presented)
            dismiss(animated: false)
        }
    }
}
