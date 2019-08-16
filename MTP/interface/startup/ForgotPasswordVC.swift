// @copyright Trollwerks Inc.

import KRProgressHUD

/// Handle prompting MTP for password reset link
final class ForgotPasswordVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.forgotPasswordVC

    @IBOutlet private var alertHolder: UIView?
    @IBOutlet private var bottomY: NSLayoutConstraint?
    @IBOutlet private var centerY: NSLayoutConstraint?
    @IBOutlet private var messageLabel: UILabel?
    @IBOutlet private var cancelButton: UIButton?
    @IBOutlet private var sendButton: UIButton?

    private var email: String = ""

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        email = data.email
        let message = L.sendLink(email.hiddenName)
        messageLabel?.text = message
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
                KRProgressHUD.showSuccess(withMessage: message)
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

extension ForgotPasswordVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIForgotPassword.cancel.expose(item: cancelButton)
        UIForgotPassword.send.expose(item: sendButton)
    }
}

// MARK: - Injectable

extension ForgotPasswordVC: Injectable {

    /// Injected dependencies
    typealias Model = ()

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        alertHolder.require()
        bottomY.require()
        centerY.require()
        messageLabel.require()
        cancelButton.require()
        sendButton.require()
    }
}
