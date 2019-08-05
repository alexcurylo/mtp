// @copyright Trollwerks Inc.

import UIKit

/// Root view for logged in user
final class MainTBC: UITabBarController, ServiceProvider {

    private typealias Segues = R.segue.myProfileVC

    private var destination: Route?

    static var current: MainTBC?

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

    func route(to mappable: Mappable) {
        dismiss(presentations: self)
        locations?.reveal(mappable: mappable, callout: true)
        selectedIndex = Route.locations.rawValue
    }

    func route(to user: User?) {
        dismiss(presentations: self)
        locations?.reveal(user: user)
        selectedIndex = Route.locations.rawValue
    }

    func route(to route: Route) {
        dismiss(presentations: self)
        destination = route
        checkDestination()
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

    var mainTBC: MainTBC? {
        if let tbc = tabBarController as? MainTBC {
            return tbc
        } else if let tbc = presentingViewController as? MainTBC {
            return tbc
        } else {
            return presentingViewController?.mainTBC
        }
    }

    func dismiss(presentations from: UIViewController) {
        if let presented = from.presentedViewController {
            dismiss(presentations: presented)
            dismiss(animated: false)
        }
    }
}
