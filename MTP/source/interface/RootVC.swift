// @copyright Trollwerks Inc.

import UIKit

final class RootVC: UIViewController {

    @IBOutlet private weak var credentials: UIView!
    @IBOutlet private weak var credentialsBottom: NSLayoutConstraint!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var signupButton: UIButton!

    private var isloggedIn: Bool {
        if let loggedIn = ProcessInfo.setting(bool: .loggedIn) {
            return loggedIn
        } else if UIApplication.isTesting {
            return false
        }

        return gestalt.isLoggedIn
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)

        if isloggedIn {
            credentials.isHidden = true
            credentialsBottom.constant = 0
            performSegue(withIdentifier: R.segue.rootVC.showMain, sender: self)
        } else {
            credentials.isHidden = false
            credentialsBottom.constant = -credentials.bounds.height
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        revealCredentials()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.info("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch true {
        case R.segue.rootVC.embedLaunchScreen(segue: segue) != nil,
             R.segue.rootVC.showMain(segue: segue) != nil,
             R.segue.rootVC.showLogin(segue: segue) != nil,
             R.segue.rootVC.showSignup(segue: segue) != nil:
            log.verbose(segue.name)
        default:
            log.warning("Unexpected segue: \(segue.name)")
        }
    }
}

private extension RootVC {

    @IBAction func unwindToRoot(segue: UIStoryboardSegue) {
        log.verbose(segue.name)
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
}
