// @copyright Trollwerks Inc.

import KRProgressHUD

final class ForgotPasswordVC: UIViewController, ServiceProvider {

    @IBOutlet private var alertHolder: UIView?
    @IBOutlet private var bottomY: NSLayoutConstraint?
    @IBOutlet private var centerY: NSLayoutConstraint?
    @IBOutlet private var messageLabel: UILabel?

    private var email: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

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

    typealias Segues = R.segue.forgotPasswordVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
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
        KRProgressHUD.show(withMessage: Localized.resettingPassword())

        // swiftlint:disable:next closure_body_length
        mtp.userForgotPassword(email: email) { [weak self] result in
            let errorMessage: String
            switch result {
            case .success(let message):
                KRProgressHUD.showSuccess(withMessage: message)
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    KRProgressHUD.dismiss()
                    self?.performSegue(withIdentifier: Segues.dismissForgotPassword, sender: self)
                }
                return
            case .failure(.status),
                 .failure(.parameter):
                errorMessage = Localized.emailError()
            case .failure(.results):
                errorMessage = Localized.resultError()
            case .failure(.message(let message)):
                errorMessage = message
            case .failure(.network(let message)):
                errorMessage = Localized.networkError(message)
            default:
                errorMessage = Localized.unexpectedError()
            }
            KRProgressHUD.showError(withMessage: errorMessage)
            DispatchQueue.main.asyncAfter(deadline: .medium) {
                KRProgressHUD.dismiss()
                self?.performSegue(withIdentifier: Segues.dismissForgotPassword, sender: self)
            }
        }
    }

    func hideAlert() {
        centerY?.priority = .defaultLow
        bottomY?.priority = .defaultHigh
        bottomY?.constant = -(alertHolder?.bounds.height ?? 0)
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
