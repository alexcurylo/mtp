// @copyright Trollwerks Inc.

import UIKit

final class RootVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.rootVC

    @IBOutlet private var credentials: UIView?
    @IBOutlet private var credentialsBottom: NSLayoutConstraint?
    @IBOutlet private var loginButton: UIButton?
    @IBOutlet private var signupButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hide(navBar: animated)

        if isloggedIn {
            credentials?.isHidden = true
            credentialsBottom?.constant = 0
            performSegue(withIdentifier: Segues.showMain, sender: self)
        } else {
            credentials?.isHidden = false
            credentialsBottom?.constant = -(credentials?.bounds.height ?? 0)
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
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        case Segues.showMain.identifier:
            let main = Segues.showMain(segue: segue)
            main?.destination.inject(model: .locations)
        case Segues.embedLaunchScreen.identifier,
             Segues.showLogin.identifier,
             Segues.showSignup.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

private extension RootVC {

    var isloggedIn: Bool {
        if let loggedIn = ProcessInfo.setting(bool: .loggedIn) {
            return loggedIn
        } else if UIApplication.isTesting {
            return false
        }

        return data.isLoggedIn
    }

    @IBAction func unwindToRoot(segue: UIStoryboardSegue) {
        log.verbose(segue.name)
    }

    func revealCredentials() {
        guard let bottom = credentialsBottom?.constant, bottom < 0 else { return }

        view.layoutIfNeeded()
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 0.75,
            options: [.curveEaseOut],
            animations: {
                self.credentialsBottom?.constant = 0
                self.view.layoutIfNeeded()
            },
            completion: nil)
    }
}

extension RootVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> RootVC {
        return self
    }

    func requireInjections() {
        credentials.require()
        credentialsBottom.require()
        loginButton.require()
        signupButton.require()
    }
}
