// @copyright Trollwerks Inc.

import UIKit

final class SignupVC: UIViewController, ServiceProvider {

    @IBOutlet private var nameTextField: UITextField?
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
        case R.segue.signupVC.pushTermsOfService.identifier,
             R.segue.signupVC.showWelcome.identifier,
             R.segue.signupVC.switchLogin.identifier,
             R.segue.signupVC.unwindFromSignup.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

private extension SignupVC {

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

    @IBAction func signupTapped(_ sender: GradientButton) {
        register()
    }

    @IBAction func facebookTapped(_ sender: FacebookButton) {
        sender.login { [weak self] name, email, id in
            self?.register(name: name, email: email, password: id)
        }
    }

    func register() {
        register(name: nameTextField?.text ?? "",
                 email: emailTextField?.text ?? "",
                 password: passwordTextField?.text ?? "")
    }

    func register(name: String, email: String, password: String) {
        mtp.userRegister(name: name, email: email, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.performSegue(withIdentifier: R.segue.signupVC.showWelcome, sender: self)
            case .failure(let error):
                self?.log.todo("handle error calling /register: \(String(describing: error))")
            }
        }
    }
}

extension SignupVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            emailTextField?.becomeFirstResponder()
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

extension SignupVC: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC is LoginVC {
            return FadeInAnimator()
        }
        return nil
    }
}
