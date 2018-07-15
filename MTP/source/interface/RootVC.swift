// @copyright Trollwerks Inc.

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

        log.debug("TO DO: implement isloggedIn")
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtons()

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

    func setupButtons() {
        loginButton.round(corners: 4)
        signupButton.round(corners: 4)

        func fixLogin() {
            loginButton.apply(gradient: [UIColor(rgb: 0x028CFF),
                                         UIColor(rgb: 0x19C0FD)],
                              orientation: .horizontal)
        }

        func fixSignup() {
            signupButton.apply(gradient: [UIColor(rgb: 0x3191CB),
                                          UIColor(rgb: 0x004B78)],
                               orientation: .horizontal)
        }

        fixLogin()
        watchLogin = observe(\.loginButton.bounds,
                             options: [.new, .old]) { _, _ in
            fixLogin()
        }

        fixSignup()
        watchSignup = observe(\.signupButton.bounds,
                              options: [.new, .old]) { _, _ in
            fixSignup()
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
        } else {
            log.error("Unexpected segue: \(String(describing: segue.identifier))")
        }
    }
}
