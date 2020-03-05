// @copyright Trollwerks Inc.

import UIKit

/// Root view for logged in user
final class MainTBC: UITabBarController {

    private typealias Segues = R.segue.myProfileVC

    // verified in requireInjection
    private var destination: Route!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    private static var current: MainTBC?

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()

        requireInjection()
        MainTBC.current = self
        checkDestination()
    }

    /// Prepare for reveal
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hide(navBar: animated)
        checkDestination()
        expose()
    }

    /// Actions to take after reveal
    /// - Parameter animated: Whether animating
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        report(screen: "Main Tab Bar")
        checkDestination()
    }

    /// Route to reveal a Mappable in Locations
    /// - Parameter mappable: Mappable to reveal
    static func route(reveal mappable: Mappable) {
        guard let current = MainTBC.current else { return }

        current.dismiss(presentations: current)
        current.locations?.reveal(mappable: mappable, callout: true)
        current.selectedIndex = Route.locations.tabIndex
    }

    /// Route to show a Mappable in Locations
    /// - Parameter mappable: Mappable to show
    static func route(show mappable: Mappable) {
        guard let current = MainTBC.current else { return }

        current.dismiss(presentations: current)
        current.locations?.show(more: mappable)
        current.selectedIndex = Route.locations.tabIndex
    }

    /// Route to display a User in Locations
    /// - Parameter user: User to display
    static func route(to user: User?) {
        guard let current = MainTBC.current else { return }

        current.dismiss(presentations: current)
        current.locations?.reveal(user: user)
        current.selectedIndex = Route.locations.tabIndex
    }

    /// Route to an enumerated destination
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
        clean(tab: .locations) as? LocationsVC
    }

    var rankings: RankingsVC? {
        clean(tab: .rankings) as? RankingsVC
    }

    var myProfile: MyProfileVC? {
        clean(tab: .myProfile) as? MyProfileVC
    }

    func checkDestination() {
        if let goto = destination {
            selectedIndex = goto.tabIndex
            switch goto {
            case .locations,
                 .rankings,
                 .myProfile:
                break
            case .editProfile:
                myProfile?.performSegue(withIdentifier: Segues.directEdit,
                                        sender: self)
            case .network,
                 .reportContent:
                myProfile?.settings(route: goto)
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
            UIMain.myProfile,
        ]
        for control in tabBar.subviews where control is UIControl {
            // this does not appear to work in 13.0
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
        viewControllers.first
    }
}
