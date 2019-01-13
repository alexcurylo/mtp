// @copyright Trollwerks Inc.

import UIKit

final class LoginVC: UIViewController {

    @IBOutlet private var emailTextField: UITextField?
    @IBOutlet private var passwordTextField: UITextField?
    @IBOutlet private var togglePasswordButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField?.rightViewMode = .always
        passwordTextField?.rightView = togglePasswordButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .login)
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
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        case R.segue.loginVC.presentForgotPassword.identifier,
             R.segue.loginVC.presentLoginFail.identifier:
            hide(navBar: true)
            gestalt.email = emailTextField?.text ?? ""
        case R.segue.loginVC.showMain.identifier,
             R.segue.loginVC.switchSignup.identifier,
             R.segue.loginVC.unwindFromLogin.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
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
        login()
    }

    @IBAction func facebookTapped(_ sender: FacebookButton) {
        sender.login { [weak self] _, email, id in
            self?.login(email: email, password: id)
        }
    }

    func login() {
        login(email: emailTextField?.text ?? "",
              password: passwordTextField?.text ?? "")
    }

    func login(email: String, password: String) {
        MTPAPI.userLogin(email: email,
                         password: password) { [weak self] result in
            switch result {
            case .success:
                self?.performSegue(withIdentifier: R.segue.loginVC.showMain, sender: self)
            case .failure(let error):
                log.todo("handle error calling /login: \(String(describing: error))")
                self?.performSegue(withIdentifier: R.segue.loginVC.presentLoginFail, sender: self)
            }
        }
    }
}

extension LoginVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField?.becomeFirstResponder()
        case passwordTextField:
            passwordTextField?.resignFirstResponder()
        default:
            break
        }
        return false
    }
}

extension LoginVC: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
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
