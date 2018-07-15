// @copyright Trollwerks Inc.

import UIKit

final class RootVC: UIViewController {

    private var isloggedIn: Bool {
        if let loggedIn = ProcessInfo.setting(bool: .loggedIn) {
            return loggedIn
        }

        log.debug("TODO: implement isloggedIn")
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if isloggedIn {
            performSegue(withIdentifier: R.segue.rootVC.showMain, sender: self)
        } else {
            log.debug("TODO: show login/signup options")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.setToolbarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if R.segue.rootVC.embedLaunchScreen(segue: segue) != nil {
            log.verbose("embedLaunchScreen")
        } else if R.segue.rootVC.showMain(segue: segue) != nil {
            log.verbose("showMain")
        } else {
            log.error("Unexpected segue: \(String(describing: segue.identifier))")
        }
    }
}
