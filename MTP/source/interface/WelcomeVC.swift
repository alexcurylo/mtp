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
        log.info("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch true {
        case R.segue.welcomeVC.showSettings(segue: segue) != nil:
            style.standard.apply()
            let settings = R.segue.welcomeVC.showSettings(segue: segue)
            settings?.destination.destination = .editProfile
            log.verbose(segue.name)
        case R.segue.welcomeVC.showMain(segue: segue) != nil:
            log.verbose(segue.name)
        default:
            log.warning("Unexpected segue: \(segue.name)")
        }
    }
}
