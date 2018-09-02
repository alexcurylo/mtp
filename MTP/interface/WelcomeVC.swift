// @copyright Trollwerks Inc.

import UIKit

final class WelcomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
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
        case R.segue.welcomeVC.showSettings.identifier:
            style.standard.apply()
            let settings = R.segue.welcomeVC.showSettings(segue: segue)
            settings?.destination.destination = .editProfile
        case R.segue.welcomeVC.showMain.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}
