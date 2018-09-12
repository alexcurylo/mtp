// @copyright Trollwerks Inc.

import UIKit

final class ForgotPasswordVC: UIViewController {

    @IBOutlet private var alertHolder: UIView?
    @IBOutlet private var bottomY: NSLayoutConstraint?
    @IBOutlet private var centerY: NSLayoutConstraint?
    @IBOutlet private var messageLabel: UILabel?

    private var email: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        email = gestalt.email
        let message = R.string.localizable.sendLink(email.hiddenName)
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
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        case R.segue.forgotPasswordVC.dismissForgotPassword.identifier:
            presentingViewController?.show(navBar: true)
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

private extension ForgotPasswordVC {

    @IBAction func continueTapped(_ sender: GradientButton) {
        MTPAPI.userForgotPassword(email: email) { [weak self] result in
            switch result {
            case .success:
                self?.performSegue(withIdentifier: R.segue.forgotPasswordVC.dismissForgotPassword, sender: self)
            case .failure(let error):
                log.error("TO DO: handle error calling /forgotPassword: \(String(describing: error))")
                self?.performSegue(withIdentifier: R.segue.forgotPasswordVC.dismissForgotPassword, sender: self)
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
