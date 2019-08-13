// @copyright Trollwerks Inc.

import UIKit

/// Notify user of login failure
final class LoginFailVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.loginFailVC

    @IBOutlet private var alertHolder: UIView?
    @IBOutlet private var bottomY: NSLayoutConstraint?
    @IBOutlet private var centerY: NSLayoutConstraint?
    @IBOutlet private var messageLabel: UILabel?
    @IBOutlet private var okButton: GradientButton?

    private var errorMessage: String?
    private var isSwitchable: Bool = true

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        if let message = errorMessage, !message.isEmpty {
            messageLabel?.text = message
            isSwitchable = false
        }
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hide(navBar: animated)
        hideAlert()
        expose()
    }

    /// Actions to take after reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        revealAlert()
    }

    /// Allow navigation
    ///
    /// - Parameters:
    ///   - identifier: Segue identifier
    ///   - sender: Action originator
    /// - Returns: Permission
    override func shouldPerformSegue(withIdentifier identifier: String,
                                     sender: Any?) -> Bool {
        switch identifier {
        case Segues.switchForgotPassword.identifier:
            return isSwitchable
        default:
            return true
        }
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.dismissLoginFail.identifier:
            presentingViewController?.show(navBar: true)
        case Segues.switchForgotPassword.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - Private

private extension LoginFailVC {

    func hideAlert() {
        centerY?.priority = .defaultLow
        bottomY?.priority = .defaultHigh
        view.setNeedsLayout()
        view.layoutIfNeeded()
        let hide = -(alertHolder?.bounds.height ?? 0)
        bottomY?.constant = hide
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func revealAlert() {
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            usingSpringWithDamping: 0.3,
            initialSpringVelocity: 0.75,
            options: [.curveEaseOut],
            animations: {
                self.bottomY?.priority = .defaultLow
                self.centerY?.priority = .defaultHigh
                self.view.layoutIfNeeded()
            },
            completion: nil)
    }
}

// MARK: - Exposing

extension LoginFailVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UILoginFail.message.expose(item: messageLabel)
        UILoginFail.ok.expose(item: okButton)
    }
}

// MARK: - Injectable

extension LoginFailVC: Injectable {

    /// Injected dependencies
    typealias Model = String

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        errorMessage = model
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        errorMessage.require()

        alertHolder.require()
        bottomY.require()
        centerY.require()
        messageLabel.require()
        okButton.require()
    }
}
