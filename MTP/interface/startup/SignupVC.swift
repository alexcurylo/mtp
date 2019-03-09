// @copyright Trollwerks Inc.

import KRProgressHUD

final class SignupVC: UIViewController, ServiceProvider {

    typealias Segues = R.segue.signupVC

    @IBOutlet private var credentialsStack: UIStackView?
    @IBOutlet private var facebookStack: UIStackView?

    @IBOutlet private var emailTextField: InsetTextField?
    @IBOutlet private var firstNameTextField: InsetTextField?
    @IBOutlet private var lastNameTextField: InsetTextField?
    @IBOutlet private var genderTextField: InsetTextField?
    @IBOutlet private var passwordTextField: InsetTextField?
    @IBOutlet private var togglePasswordButton: UIButton?
    @IBOutlet private var confirmPasswordTextField: InsetTextField?
    @IBOutlet private var toggleConfirmPasswordButton: UIButton?

    private var errorMessage: String = ""

    let genders = [Localized.selectGender(), Localized.male(), Localized.female()]

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField?.text = data.email

        _ = UIPickerView().with {
            $0.dataSource = self
            $0.delegate = self
            genderTextField?.inputView = $0
        }

        passwordTextField?.rightViewMode = .always
        passwordTextField?.rightView = togglePasswordButton

        confirmPasswordTextField?.rightViewMode = .always
        confirmPasswordTextField?.rightView = toggleConfirmPasswordButton
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

        data.email = emailTextField?.text ?? ""
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
        let textField: InsetTextField?
        switch sender {
        case togglePasswordButton:
            textField = passwordTextField
        case toggleConfirmPasswordButton:
            textField = confirmPasswordTextField
        default:
            textField = nil
        }
        guard let field = textField else { return }

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
        sender.login { [weak self] info in
            guard let self = self else { return }
            guard let info = info else {
                self.errorMessage = Localized.facebookFailed()
                self.performSegue(withIdentifier: Segues.presentSignupFail, sender: self)
                return
            }

            if let stack = self.credentialsStack,
                let fbStack = self.facebookStack {
                stack.removeArrangedSubview(fbStack)
                fbStack.removeFromSuperview()
            }

            self.emailTextField?.disable(text: info.email)
            self.firstNameTextField?.disable(text: info.first_name)
            let gender: String
            switch info.gender {
            case "M": gender = Localized.male()
            case "F": gender = Localized.female()
            default: gender = ""
            }
            self.genderTextField?.disable(text: gender)
            self.lastNameTextField?.disable(text: info.last_name)

            self.prepareRegister(showError: false)
        }
    }

    func prepareRegister(showError: Bool) {
        let email = emailTextField?.text ?? ""
        let firstName = firstNameTextField?.text ?? ""
        let lastName = lastNameTextField?.text ?? ""
        let gender: String
        if let first = genderTextField?.text?.first {
            gender = String(first)
        } else {
            gender = ""
        }
        let password = passwordTextField?.text ?? ""
        let passwordConfirmation = confirmPasswordTextField?.text ?? ""

        if !email.isValidEmail {
            errorMessage = Localized.fixEmail()
        } else if firstName.isEmpty {
            errorMessage = Localized.fixFirstName()
        } else if lastName.isEmpty {
            errorMessage = Localized.fixLastName()
        } else if gender.isEmpty {
            errorMessage = Localized.fixGender()
        } else if !password.isValidPassword {
            errorMessage = Localized.fixPassword()
        } else if password != passwordConfirmation {
            errorMessage = Localized.fixConfirmPassword()
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
            firstName: firstName,
            email: email,
            location: Location(),
            gender: gender,
            lastName: lastName,
            password: password,
            passwordConfirmation: passwordConfirmation
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
        case emailTextField:
            firstNameTextField?.becomeFirstResponder()
        case firstNameTextField:
            lastNameTextField?.becomeFirstResponder()
        case lastNameTextField:
            genderTextField?.becomeFirstResponder()
        case genderTextField:
            passwordTextField?.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField?.becomeFirstResponder()
        case confirmPasswordTextField:
            confirmPasswordTextField?.resignFirstResponder()
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

extension SignupVC: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
}

extension SignupVC: UIPickerViewDelegate {

    public func pickerView(_ pickerView: UIPickerView,
                           titleForRow row: Int,
                           forComponent component: Int) -> String? {
        return genders[row]
    }

    public func pickerView(_ pickerView: UIPickerView,
                           didSelectRow row: Int,
                           inComponent component: Int) {
        guard row > 0 else { return }
        genderTextField?.text = genders[row]
        genderTextField?.resignFirstResponder()
    }
}
