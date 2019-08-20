// @copyright Trollwerks Inc.

import UIKit

/// Notify user of signup failure
final class SignupFailVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.signupFailVC

    // verified in requireOutlets
    @IBOutlet private var alertHolder: UIView!
    @IBOutlet private var bottomY: NSLayoutConstraint!
    @IBOutlet private var centerY: NSLayoutConstraint!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var okButton: GradientButton!

    // verified in requireInjection
    private var errorMessage: String!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()
        requireInjection()

        if !errorMessage.isEmpty {
            messageLabel.text = errorMessage
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
        bottomY.constant = -alertHolder.bounds.height
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
                self.bottomY.priority = .defaultLow
                self.centerY.priority = .defaultHigh
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

// MARK: - InterfaceBuildable

extension SignupFailVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        alertHolder.require()
        bottomY.require()
        centerY.require()
        messageLabel.require()
        okButton.require()
    }
}

// MARK: - Injectable

extension SignupFailVC: Injectable {

    /// Injected dependencies
    typealias Model = String

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    func inject(model: Model) {
        errorMessage = model
    }

    /// Enforce dependency injection
    func requireInjection() {
        errorMessage.require()
    }
}
