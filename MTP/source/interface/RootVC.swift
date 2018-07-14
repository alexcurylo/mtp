// @copyright Trollwerks Inc.

import UIKit

final class RootVC: UIViewController {

    private var loggedIn: Bool {
        log.warning("TODO: implement loggedIn")
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if loggedIn {
            performSegue(withIdentifier: R.segue.rootVC.showMain, sender: self)
        } else {
            performSegue(withIdentifier: R.segue.rootVC.showLaunch, sender: self)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if R.segue.rootVC.showMain(segue: segue) != nil {
            log.debug("Seguing to main")
        } else if R.segue.rootVC.showLaunch(segue: segue) != nil {
            log.debug("Seguing to launch")
        } else {
            log.error("Unexpected segue received")
        }
    }
}
