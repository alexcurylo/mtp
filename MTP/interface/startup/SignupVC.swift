// @copyright Trollwerks Inc.

import KRProgressHUD

final class SignupVC: UIViewController, ServiceProvider {

    typealias Segues = R.segue.signupVC

    @IBOutlet private var nameTextField: UITextField?
    @IBOutlet private var emailTextField: UITextField?
    @IBOutlet private var passwordTextField: UITextField?
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
        view.endEditing(true)
        switch segue.identifier {
        case Segues.presentSignupFail.identifier:
            let alert = Segues.presentSignupFail(segue: segue)
            alert?.destination.errorMessage = errorMessage
            hide(navBar: true)
        case Segues.pushTermsOfService.identifier,
             Segues.showWelcome.identifier,
             Segues.switchLogin.identifier,
             Segues.unwindFromSignup.identifier:
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
        view.endEditing(true)
        prepareRegister(showError: true)
    }

    @IBAction func facebookTapped(_ sender: FacebookButton) {
        view.endEditing(true)
        sender.login { [weak self] name, email, _ in
            guard let self = self else { return }

            self.log.todo("populate from Facebook")
            self.nameTextField?.text = name
            self.emailTextField?.text = email
            self.prepareRegister(showError: false)
        }
    }

    func prepareRegister(showError: Bool) {
        log.todo("validate all fields")
        let name = nameTextField?.text ?? ""
        let email = emailTextField?.text ?? ""
        let password = passwordTextField?.text ?? ""
        if name.isEmpty {
            errorMessage = "fix name"
        } else if !email.isValidEmail {
            errorMessage = Localized.fixEmail()
        } else if !password.isValidPassword {
            errorMessage = Localized.fixPassword()
        } else {
            errorMessage = ""
        }
        guard errorMessage.isEmpty else {
            if showError {
                performSegue(withIdentifier: Segues.presentSignupFail, sender: self)
            }
            return
        }

        let info = RegistrationInfo(
            birthday: Date(),
            country: Country(),
            firstName: name,
            email: email,
            gender: .all,
            lastName: name,
            location: Location(),
            password: password,
            passwordConfirmation: ""
        )

        register(info: info)
    }

    func register(info: RegistrationInfo) {
        KRProgressHUD.show(withMessage: Localized.signingUp())
        mtp.userRegister(info: info) { [weak self] result in
            switch result {
            case .success:
                KRProgressHUD.showSuccess(withMessage: Localized.success())
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    KRProgressHUD.dismiss()
                    self?.performSegue(withIdentifier: Segues.showWelcome, sender: self)
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
            self?.performSegue(withIdentifier: Segues.presentSignupFail, sender: self)
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
            prepareRegister(showError: false)
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

extension SignupVC: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ZoomAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}
