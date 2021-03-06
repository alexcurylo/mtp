// @copyright Trollwerks Inc.

import Anchorage

/// Application root containing signup and logged in UI
final class RootVC: UIViewController {

    private typealias Segues = R.segue.rootVC

    // verified in requireOutlets
    @IBOutlet private var credentials: UIView!
    @IBOutlet private var credentialsBottom: NSLayoutConstraint!
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var signupButton: UIButton!

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()

        requireOutlets()
        setLightMode()
        setApplicationBackground()
    }

    /// :nodoc:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard !UIApplication.isUnitTesting else { return }

        if data.isLoggedIn {
            credentials.isHidden = true
            credentialsBottom.constant = 0
            performSegue(withIdentifier: Segues.showMain, sender: self)
        } else if let credentials = credentials {
            credentials.isHidden = false
            credentialsBottom.constant = -credentials.bounds.height
            expose()
       }
    }

    /// :nodoc:
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !UIApplication.isUnitTesting else { return }

        report(screen: "Root")

        let bottom = credentialsBottom.constant
        if bottom < 0 {
            revealCredentials(bottom: bottom)
        }
    }

    /// :nodoc:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let main = Segues.showMain(segue: segue)?
                            .destination {
            main.inject(model: .locations)
        }
    }
}

// MARK: - Private

private extension RootVC {

    @IBAction func unwindToRoot(segue: UIStoryboardSegue) { }

    func revealCredentials(bottom: CGFloat) {
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

    func setApplicationBackground() {
        if let first = UIApplication.shared.windows.first {
            let background = GradientView {
                $0.set(gradient: [.dodgerBlue, .azureRadiance],
                       orientation: .topRightBottomLeft)
            }
            first.insertSubview(background, at: 0)
            background.edgeAnchors == first.edgeAnchors
        }
    }
}

// MARK: - Exposing

extension RootVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIRoot.login.expose(item: loginButton)
        UIRoot.signup.expose(item: signupButton)
    }
}

// MARK: - InterfaceBuildable

extension RootVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        credentials.require()
        credentialsBottom.require()
        loginButton.require()
        signupButton.require()
    }
}
