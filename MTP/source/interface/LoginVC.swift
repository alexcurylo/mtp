// @copyright Trollwerks Inc.

import UIKit

final class LoginVC: UIViewController {

    @IBOutlet private weak var emailTextField: UITextField?
    @IBOutlet private weak var passwordTextField: UITextField?
    @IBOutlet private weak var togglePasswordButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField?.rightViewMode = .always
        passwordTextField?.rightView = togglePasswordButton
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
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch true {
        case R.segue.loginVC.presentForgotPassword(segue: segue) != nil,
             R.segue.loginVC.presentLoginFail(segue: segue) != nil:
            navigationController?.setNavigationBarHidden(true, animated: true)
            gestalt.email = emailTextField?.text ?? ""
            log.verbose(segue.name)
        case R.segue.loginVC.showMain(segue: segue) != nil:
            style.standard.apply()
            log.verbose(segue.name)
        case R.segue.loginVC.switchSignup(segue: segue) != nil,
             R.segue.loginVC.unwindFromLogin(segue: segue) != nil:
            log.verbose(segue.name)
        default:
            log.debug("Unexpected segue: \(segue.name)")
        }
    }
}

private extension LoginVC {

    @IBAction func visibilityTapped(_ sender: UIButton) {
        guard let field = passwordTextField else { return }

        if sender.isSelected {
            sender.isSelected = false
            field.isSecureTextEntry = true
        } else {
            sender.isSelected = true
            field.isSecureTextEntry = false
        }

        if let existingText = field.text,
           let textRange = field.textRange(from: field.beginningOfDocument,
                                           to: field.endOfDocument) {
            field.deleteBackward()
            field.replace(textRange, withText: existingText)
        }
    }

    @IBAction func loginTapped(_ sender: GradientButton) {
        login(email: emailTextField?.text ?? "",
              password: passwordTextField?.text ?? "")
    }

    @IBAction func facebookTapped(_ sender: FacebookButton) {
        sender.login { [weak self] _, email, id in
            self?.login(email: email, password: id)
        }
    }

    func login(email: String, password: String) {
        MTPAPI.login(email: email, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.performSegue(withIdentifier: R.segue.loginVC.showMain, sender: self)
            case .failure(let error):
                log.error("TO DO: handle error calling /login: \(String(describing: error))")
                self?.performSegue(withIdentifier: R.segue.loginVC.presentLoginFail, sender: self)
            }
        }
    }
}

extension LoginVC: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationControllerOperation,
        from fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC is SignupVC {
            return FadeInAnimator()
        }
        return nil
    }
}

extension LoginVC: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ZoomAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}
