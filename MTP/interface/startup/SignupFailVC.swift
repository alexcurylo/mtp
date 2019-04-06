// @copyright Trollwerks Inc.

import UIKit

final class SignupFailVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.signupFailVC

    @IBOutlet private var alertHolder: UIView?
    @IBOutlet private var bottomY: NSLayoutConstraint?
    @IBOutlet private var centerY: NSLayoutConstraint?
    @IBOutlet private var messageLabel: UILabel?

    var errorMessage: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        if let message = errorMessage, !message.isEmpty {
            messageLabel?.text = message
        }
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
        case Segues.dismissSignupFail.identifier:
            presentingViewController?.show(navBar: true)
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

private extension SignupFailVC {

    func hideAlert() {
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

extension SignupFailVC: Injectable {

    typealias Model = String

    @discardableResult func inject(model: Model) -> SignupFailVC {
        errorMessage = model
        return self
    }

    func requireInjections() {
        errorMessage.require()

        alertHolder.require()
        bottomY.require()
        centerY.require()
        messageLabel.require()
    }
}
