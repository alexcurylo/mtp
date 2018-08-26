// @copyright Trollwerks Inc.

import UIKit

final class LoginFailVC: UIViewController {

    @IBOutlet private weak var alertHolder: UIView!
    @IBOutlet private weak var bottomY: NSLayoutConstraint!
    @IBOutlet private weak var centerY: NSLayoutConstraint!
    @IBOutlet private weak var messageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
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
        switch true {
        case R.segue.loginFailVC.dismissLoginFail(segue: segue) != nil:
            presentingViewController?.navigationController?.setNavigationBarHidden(false, animated: true)
            log.verbose(segue.name)
        case R.segue.loginFailVC.switchForgotPassword(segue: segue) != nil:
            log.verbose(segue.name)
        default:
            log.debug("Unexpected segue: \(segue.name)")
        }
    }
}

private extension LoginFailVC {

    func hideAlert() {
        centerY.priority = .defaultLow
        bottomY.priority = .defaultHigh
        bottomY.constant = -alertHolder.bounds.height
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
