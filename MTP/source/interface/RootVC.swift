// @copyright Trollwerks Inc.

import FacebookCore
import UIKit

final class RootVC: UIViewController {

    @IBOutlet private weak var credentials: UIView!
    @IBOutlet private weak var credentialsBottom: NSLayoutConstraint!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var signupButton: UIButton!

    private var watchLogin: NSKeyValueObservation?
    private var watchSignup: NSKeyValueObservation?

    private var isloggedIn: Bool {
        if let loggedIn = ProcessInfo.setting(bool: .loggedIn) {
            return loggedIn
        }

        if let accessToken = AccessToken.current {
            log.info("Logged in with Facebook: \(accessToken.userId ?? "??")")
            return true
        }

        log.debug("TO DO: implement isloggedIn")
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if isloggedIn {
            performSegue(withIdentifier: R.segue.rootVC.showMain, sender: self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)

        if isloggedIn {
            credentials.isHidden = true
            credentialsBottom.constant = 0
        } else {
            credentials.isHidden = false
            credentialsBottom.constant = -credentials.bounds.height
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        revealCredentials()
    }

    func revealCredentials() {
        guard credentialsBottom.constant < 0 else { return }

        view.layoutIfNeeded()
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 0.75,
            options: [.curveEaseOut],
            animations: {
                self.credentialsBottom.constant = 0
                self.view.layoutIfNeeded()
            },
            completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        } else if R.segue.rootVC.showLogin(segue: segue) != nil {
            log.verbose("showLogin")
        } else if R.segue.rootVC.showSignup(segue: segue) != nil {
            log.verbose("showSignup")
        } else if R.segue.signupVC.unwindFromSignup(segue: segue) != nil {
            log.verbose("unwindFromSignup")
        } else if R.segue.loginVC.unwindFromLogin(segue: segue) != nil {
            log.verbose("showMain")
        } else {
            log.warning("Unexpected segue: \(String(describing: segue.identifier))")
        }
    }

    @IBAction private func unwindToRoot(segue: UIStoryboardSegue) { }
}
