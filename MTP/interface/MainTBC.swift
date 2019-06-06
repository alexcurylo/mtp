// @copyright Trollwerks Inc.

import UIKit

final class MainTBC: UITabBarController, ServiceProvider {

    private typealias Segues = R.segue.myProfileVC

    enum Route: Int {
        // tabs
        case locations = 0
        case rankings = 1
        case myProfile = 2
        // presentations
        case editProfile
    }

    private var destination: Route?

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        checkDestination()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hide(navBar: animated)
        checkDestination()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkDestination()
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }

    func route(to user: User?) {
        dismiss(presentations: self)
        locations?.reveal(user: user)
        selectedIndex = Route.locations.rawValue
    }

    func route(to annotation: PlaceAnnotation) {
        dismiss(presentations: self)
        locations?.reveal(place: annotation, callout: true)
        selectedIndex = Route.locations.rawValue
    }
}

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

extension MainTBC: Injectable {

    typealias Model = Route

    @discardableResult func inject(model: Model) -> Self {
        destination = model
        return self
    }

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
