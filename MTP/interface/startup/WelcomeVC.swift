// @copyright Trollwerks Inc.

import UIKit

final class WelcomeVC: UIViewController, ServiceProvider {

    typealias Segues = R.segue.welcomeVC

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hide(navBar: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        case Segues.showSettings.identifier:
            let settings = Segues.showSettings(segue: segue)
            settings?.destination.destination = .editProfile
        case Segues.showMain.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}
