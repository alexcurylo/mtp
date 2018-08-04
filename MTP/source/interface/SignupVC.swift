// @copyright Trollwerks Inc.

import UIKit

final class SignupVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        style.login.apply()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.delegate = nil
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.info("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch true {
        case R.segue.signupVC.unwindFromSignup(segue: segue) != nil,
             R.segue.signupVC.switchLogin(segue: segue) != nil:
            log.verbose(segue.name)
        default:
            log.warning("Unexpected segue: \(segue.name)")
        }
    }
}

private extension SignupVC {

    @IBAction func facebookTapped(_ sender: FacebookButton) {
        sender.login { name, email in
            MTPAPI.register(name: name, email: email) { success in
                guard success else { return }
                UserDefaults.standard.email = email
                UserDefaults.standard.name = name
                self.performSegue(withIdentifier: R.segue.signupVC.showMain, sender: self)
            }
        }
    }
}

extension SignupVC: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationControllerOperation,
        from fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC is LoginVC {
            return FadeInAnimator()
        }
        return nil
    }
}
