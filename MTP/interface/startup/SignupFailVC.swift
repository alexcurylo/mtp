// @copyright Trollwerks Inc.

import UIKit

/// Notify user of signup failure
final class SignupFailVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.signupFailVC

    @IBOutlet private var alertHolder: UIView?
    @IBOutlet private var bottomY: NSLayoutConstraint?
    @IBOutlet private var centerY: NSLayoutConstraint?
    @IBOutlet private var messageLabel: UILabel?
    @IBOutlet private var okButton: GradientButton?

    private var errorMessage: String?

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        if let message = errorMessage, !message.isEmpty {
            messageLabel?.text = message
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

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.dismissSignupFail.identifier {
            presentingViewController?.show(navBar: true)
        }
    }
}

// MARK: - Private

private extension SignupFailVC {

    func hideAlert() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        if let height = alertHolder?.bounds.height {
            bottomY?.constant = -height
        }
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

extension SignupFailVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UISignupFail.message.expose(item: messageLabel)
        UISignupFail.ok.expose(item: okButton)
    }
}

// MARK: - Injectable

extension SignupFailVC: Injectable {

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
