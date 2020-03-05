// @copyright Trollwerks Inc.

import UIKit

/// Notify user of login failure
final class LoginFailVC: UIViewController {

    private typealias Segues = R.segue.loginFailVC

    // verified in requireOutlets
    @IBOutlet private var alertHolder: UIView!
    @IBOutlet private var bottomY: NSLayoutConstraint!
    @IBOutlet private var centerY: NSLayoutConstraint!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var forgotButton: UIButton!
    @IBOutlet private var okButton: GradientButton!

    // verified in requireInjection
    private var errorMessage: String!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    private var isSwitchable: Bool = true

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()

        requireOutlets()
        requireInjection()

        if errorMessage.isEmpty {
            isSwitchable = true
        } else {
            messageLabel.text = errorMessage
            isSwitchable = false
        }
    }

    /// :nodoc:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hide(navBar: animated)
        hideAlert()
        expose()
    }

    /// :nodoc:
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        report(screen: "Login Fail")

        revealAlert()
    }

    /// Allow navigation
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

    /// :nodoc:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.dismissLoginFail.identifier {
            presentingViewController?.show(navBar: true)
        }
    }
}

// MARK: - Private

private extension LoginFailVC {

    func hideAlert() {
        centerY.priority = .defaultLow
        bottomY.priority = .defaultHigh
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

extension LoginFailVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UILoginFail.message.expose(item: messageLabel)
        UILoginFail.forgot.expose(item: forgotButton)
        UILoginFail.ok.expose(item: okButton)
    }
}

// MARK: - InterfaceBuildable

extension LoginFailVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        alertHolder.require()
        bottomY.require()
        centerY.require()
        forgotButton.require()
        messageLabel.require()
        okButton.require()
    }
}

// MARK: - Injectable

extension LoginFailVC: Injectable {

    /// Injected dependencies
    typealias Model = String

    /// Handle dependency injection
    /// - Parameter model: Dependencies
    func inject(model: Model) {
        errorMessage = model
    }

    /// Enforce dependency injection
    func requireInjection() {
        errorMessage.require()
     }
}
