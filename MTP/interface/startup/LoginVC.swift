// @copyright Trollwerks Inc.

import KRProgressHUD

final class LoginVC: UIViewController, ServiceProvider {

    typealias Segues = R.segue.loginVC

    @IBOutlet private var emailTextField: InsetTextField?
    @IBOutlet private var passwordTextField: InsetTextField?
    @IBOutlet private var togglePasswordButton: UIButton?

    private var errorMessage: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField?.rightViewMode = .always
        passwordTextField?.rightView = togglePasswordButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .login)
        navigationController?.delegate = self

        emailTextField?.text = data.email
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.delegate = nil

        data.email = emailTextField?.text ?? ""
   }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case Segues.presentForgotPassword.identifier:
            guard let email = emailTextField?.text, email.isValidEmail else {
                errorMessage = Localized.fixEmail()
                performSegue(withIdentifier: Segues.presentLoginFail, sender: self)
                return false
            }
            return true
        default:
            return true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        view.endEditing(true)
        switch segue.identifier {
        case Segues.presentLoginFail.identifier:
            let alert = Segues.presentLoginFail(segue: segue)
            alert?.destination.errorMessage = errorMessage
            hide(navBar: true)
            data.email = emailTextField?.text ?? ""
        case Segues.presentForgotPassword.identifier:
            hide(navBar: true)
            data.email = emailTextField?.text ?? ""
        case Segues.showMain.identifier,
             Segues.switchSignup.identifier,
             Segues.unwindFromLogin.identifier:
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
        view.endEditing(true)
        prepareLogin(showError: true)
    }

    @IBAction func facebookTapped(_ sender: FacebookButton) {
        view.endEditing(true)
        sender.login { [weak self] _, email, _ in
            self?.emailTextField?.text = email
            // currently not implemented: login with Facebook ID
        }
    }

    func prepareLogin(showError: Bool) {
        let email = emailTextField?.text ?? ""
        let password = passwordTextField?.text ?? ""
        if !email.isValidEmail {
            errorMessage = Localized.fixEmail()
        } else if !password.isValidPassword {
            errorMessage = Localized.fixPassword()
        } else {
            errorMessage = ""
        }
        guard errorMessage.isEmpty else {
            if showError {
                performSegue(withIdentifier: Segues.presentLoginFail, sender: self)
            }
            return
        }
        login(email: email, password: password)
    }

    func login(email: String, password: String) {
        KRProgressHUD.show(withMessage: Localized.loggingIn())
        mtp.userLogin(email: email,
                      password: password) { [weak self] result in
            switch result {
            case .success:
                KRProgressHUD.showSuccess(withMessage: Localized.success())
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    KRProgressHUD.dismiss()
                    self?.performSegue(withIdentifier: Segues.showMain, sender: self)
                }
                return
            case .failure(.status),
                 .failure(.results):
                self?.errorMessage = Localized.resultError()
            case .failure(.network(let message)):
                self?.errorMessage = Localized.networkError(message)
            default:
                self?.errorMessage = Localized.unexpectedError()
            }
            KRProgressHUD.dismiss()
            self?.performSegue(withIdentifier: Segues.presentLoginFail, sender: self)
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
            prepareLogin(showError: false)
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
