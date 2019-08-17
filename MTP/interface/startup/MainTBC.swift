// @copyright Trollwerks Inc.

import UIKit

/// Root view for logged in user
final class MainTBC: UITabBarController, ServiceProvider {

    private typealias Segues = R.segue.myProfileVC

    // verified in requireInjection
    private var destination: Route!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    private static var current: MainTBC?

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjection()

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

    /// Route to display a Mappable in Locations
    ///
    /// - Parameter mappable: Mappable to display
    static func route(to mappable: Mappable) {
        guard let current = MainTBC.current else { return }

        current.dismiss(presentations: current)
        current.locations?.reveal(mappable: mappable, callout: true)
        current.selectedIndex = Route.locations.tabIndex
    }

    /// Route to display a User in Locations
    ///
    /// - Parameter user: User to display
    static func route(to user: User?) {
        guard let current = MainTBC.current else { return }

        current.dismiss(presentations: current)
        current.locations?.reveal(user: user)
        current.selectedIndex = Route.locations.tabIndex
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

    /// Dismiss any presented controllers
    static func dismissPresentations() {
        guard let current = MainTBC.current else { return }

        current.dismiss(presentations: current)
        current.clean(tab: .locations)
        current.clean(tab: .rankings)
        current.clean(tab: .myProfile)
    }
}

// MARK: - Private

private extension MainTBC {

    @discardableResult func clean(tab: Route) -> UIViewController? {
        guard let nav = viewControllers?[tab.tabIndex] as? UINavigationController else { return nil }

        if nav.viewControllers.count > 1 {
            let root = [nav.viewControllers[0]]
            nav.viewControllers = root
        }
        return nav.root
    }

    var locations: LocationsVC? {
        return clean(tab: .locations) as? LocationsVC
    }

    var rankings: RankingsVC? {
        return clean(tab: .rankings) as? RankingsVC
    }

    var myProfile: MyProfileVC? {
        return clean(tab: .myProfile) as? MyProfileVC
    }

    func checkDestination() {
        if let goto = destination {
            switch goto {
            case .locations, .rankings, .myProfile:
                selectedIndex = goto.tabIndex
            case .editProfile:
                selectedIndex = Route.myProfile.tabIndex
                myProfile?.performSegue(withIdentifier: Segues.directEdit, sender: self)
            case .reportContent(let message):
                selectedIndex = Route.myProfile.tabIndex
                myProfile?.reportContent(message: message)
            }
        }

        destination = nil
    }
}

// MARK: - Exposing

extension MainTBC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIMain.bar.expose(item: tabBar)
        var buttons = [
            UIMain.locations,
            UIMain.rankings,
            UIMain.myProfile
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
    func inject(model: Model) {
        destination = model
    }

    /// Enforce dependency injection
    func requireInjection() {
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

private extension UINavigationController {

    var root: UIViewController? {
        return viewControllers.first
    }
}
