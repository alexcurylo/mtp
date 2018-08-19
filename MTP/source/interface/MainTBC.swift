// @copyright Trollwerks Inc.

import UIKit

final class MainTBC: UITabBarController {

    enum Route: Int {
        // Tabs
        case locations = 0
        case rankings = 1
        case myProfile = 2
        // Presentations
        case editProfile
    }

    var destination: Route?

    var locations: LocationsVC? {
        return viewControllers?[Route.locations.rawValue] as? LocationsVC
    }

    var rankings: RankingsVC? {
        return viewControllers?[Route.rankings.rawValue] as? RankingsVC
    }

    var myProfileNav: UINavigationController? {
        return viewControllers?[Route.myProfile.rawValue] as? UINavigationController
    }

    var myProfile: MyProfileVC? {
        return myProfileNav?.topViewController as? MyProfileVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        checkDestination()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkDestination()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkDestination()
    }

    override func didReceiveMemoryWarning() {
        log.info("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.warning("Unexpected segue: \(segue.name)")
    }
}

private extension MainTBC {

    func checkDestination() {
        guard let goto = destination else { return }

        switch goto {
        case .locations, .rankings, .myProfile:
            selectedIndex = goto.rawValue
        case .editProfile:
            selectedIndex = Route.myProfile.rawValue
            myProfile?.performSegue(withIdentifier: R.segue.myProfileVC.directEdit, sender: self)
        }

        destination = nil
    }
}