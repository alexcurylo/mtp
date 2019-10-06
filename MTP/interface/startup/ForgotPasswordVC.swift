// @copyright Trollwerks Inc.

import UIKit

/// Handle prompting MTP for password reset link
final class ForgotPasswordVC: UIViewController {

    private typealias Segues = R.segue.forgotPasswordVC

    // verified in requireOutlets
    @IBOutlet private var alertHolder: UIView!
    @IBOutlet private var bottomY: NSLayoutConstraint!
    @IBOutlet private var centerY: NSLayoutConstraint!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var cancelButton: UIButton!
    @IBOutlet private var sendButton: UIButton!

    private var email: String = ""

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()

        email = data.email
        let message = L.sendLink(email.hiddenName)
        messageLabel.text = message
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
        report(screen: "Forgot Password")

        revealAlert()
    }

    /// :nodoc:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.dismissForgotPassword.identifier {
            presentingViewController?.show(navBar: true)
        }
    }
}

// MARK: - Private

private extension ForgotPasswordVC {

    @IBAction func continueTapped(_ sender: GradientButton) {
        note.modal(info: L.resettingPassword())

        net.userForgotPassword(email: email) { [weak self, note] result in
            switch result {
            case .success(let message):
                note.modal(success: message)
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    note.dismissModal()
                    self?.performSegue(withIdentifier: Segues.dismissForgotPassword, sender: self)
                }
                return
            case .failure(let error):
                note.modal(failure: error,
                           operation: L.resetPassword())
                DispatchQueue.main.asyncAfter(deadline: .medium) {
                    self?.performSegue(withIdentifier: Segues.dismissForgotPassword, sender: self)
                }
            }
        }
    }

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

extension ForgotPasswordVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIForgotPassword.cancel.expose(item: cancelButton)
        UIForgotPassword.send.expose(item: sendButton)
    }
}

// MARK: - InterfaceBuildable

extension ForgotPasswordVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        alertHolder.require()
        bottomY.require()
        centerY.require()
        messageLabel.require()
        cancelButton.require()
        sendButton.require()
    }
}
