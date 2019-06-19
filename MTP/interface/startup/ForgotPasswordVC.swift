// @copyright Trollwerks Inc.

import KRProgressHUD

final class ForgotPasswordVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.forgotPasswordVC

    @IBOutlet private var alertHolder: UIView?
    @IBOutlet private var bottomY: NSLayoutConstraint?
    @IBOutlet private var centerY: NSLayoutConstraint?
    @IBOutlet private var messageLabel: UILabel?

    private var email: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        email = data.email
        let message = Localized.sendLink(email.hiddenName)
        messageLabel?.text = message
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hide(navBar: animated)
        hideAlert()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        revealAlert()
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.dismissForgotPassword.identifier:
            presentingViewController?.show(navBar: true)
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

private extension ForgotPasswordVC {

    @IBAction func continueTapped(_ sender: GradientButton) {
        let operation = Localized.resetPassword()
        note.modal(info: Localized.resettingPassword())

        // swiftlint:disable:next closure_body_length
        mtp.userForgotPassword(email: email) { [weak self, note] result in
            let errorMessage: String
            switch result {
            case .success(let message):
                KRProgressHUD.showSuccess(withMessage: message)
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    note.dismissModal()
                    self?.performSegue(withIdentifier: Segues.dismissForgotPassword, sender: self)
                }
                return
            case .failure(.deviceOffline):
                errorMessage = Localized.deviceOfflineError(operation)
            case .failure(.serverOffline):
                errorMessage = Localized.serverOfflineError(operation)
            case .failure(.status),
                 .failure(.parameter):
                errorMessage = Localized.emailError()
            case .failure(.decoding),
                 .failure(.result):
                errorMessage = Localized.resultsErrorReport(operation)
            case .failure(.message(let message)):
                errorMessage = message
            case .failure(.network(let message)):
                errorMessage = Localized.networkError(operation, message)
            default:
                errorMessage = Localized.unexpectedErrorReport(operation)
            }
            KRProgressHUD.showError(withMessage: errorMessage)
            DispatchQueue.main.asyncAfter(deadline: .medium) {
                note.dismissModal()
                self?.performSegue(withIdentifier: Segues.dismissForgotPassword, sender: self)
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

extension ForgotPasswordVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    func requireInjections() {
        alertHolder.require()
        bottomY.require()
        centerY.require()
        messageLabel.require()
    }
}
