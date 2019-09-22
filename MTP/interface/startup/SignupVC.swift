// @copyright Trollwerks Inc.

import RealmSwift
import UIKit

// swiftlint:disable file_length

/// Handle the user signup process
final class SignupVC: UIViewController {

    private typealias Segues = R.segue.signupVC

    /// verified in requireOutlets
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var credentialsStack: UIStackView!
    @IBOutlet private var facebookStack: UIStackView!
    @IBOutlet private var facebookButton: FacebookButton!
    @IBOutlet private var fieldsStack: UIStackView!
    @IBOutlet private var emailTextField: InsetTextField!
    @IBOutlet private var firstNameTextField: InsetTextField!
    @IBOutlet private var lastNameTextField: InsetTextField!
    @IBOutlet private var genderTextField: InsetTextField!
    @IBOutlet private var countryTextField: InsetTextField!
    @IBOutlet private var locationTextField: InsetTextField!
    @IBOutlet private var birthdayTextField: InsetTextField!
    @IBOutlet private var passwordTextField: InsetTextField!
    @IBOutlet private var togglePasswordButton: UIButton!
    @IBOutlet private var confirmPasswordTextField: InsetTextField!
    @IBOutlet private var toggleConfirmPasswordButton: UIButton!
    @IBOutlet private var termsOfServiceButton: UIButton!
    @IBOutlet private var signupButton: UIButton!
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var keyboardToolbar: UIToolbar!
    @IBOutlet private var toolbarBackButton: UIBarButtonItem!
    @IBOutlet private var toolbarNextButton: UIBarButtonItem!
    @IBOutlet private var toolbarClearButton: UIBarButtonItem!
    @IBOutlet private var toolbarDoneButton: UIBarButtonItem!

    private var errorMessage: String = ""
    private var agreed = false
    private var country: Country?
    private var location: Location?
    private var method: AnalyticsEvent.Method = .email

    private let genders = [L.selectGender(),
                           L.male(),
                           L.female(),
                           L.preferNot()]

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()

        setupView()
        startKeyboardListening()
   }

    /// :nodoc:
    deinit {
        stopKeyboardListening()
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .login)
        navigationController?.delegate = self
        expose()
    }

    /// Actions to take after reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(screen: "Sign Up")
    }

    /// Prepare for hide
    ///
    /// - Parameter animated: Whether animating
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.delegate = nil

        data.email = emailTextField.text ?? ""
   }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        view.endEditing(true)
        if let target = Segues.showCountry(segue: segue)?
            .destination
            .topViewController as? LocationSearchVC {
            target.inject(mode: .countryOrPreferNot,
                          styler: .standard,
                          delegate: self)
        } else if let target = Segues.showLocation(segue: segue)?
                                     .destination
                                     .topViewController as? LocationSearchVC {
            let countryId = country?.countryId ?? 0
            target.inject(mode: .location(country: countryId),
                          styler: .standard,
                          delegate: self)
        } else if let alert = Segues.presentSignupFail(segue: segue)?
                                    .destination {
            alert.inject(model: errorMessage)
            hide(navBar: true)
        }
    }
}

// MARK: - KeyboardListener

extension SignupVC: KeyboardListener {

    /// Scroll view for keyboard avoidance
    var keyboardScrollee: UIScrollView? { return scrollView }
}

// MARK: - Private

private extension SignupVC {

    func setupView() {
        emailTextField.text = data.email
        emailTextField.inputAccessoryView = keyboardToolbar

        firstNameTextField.inputAccessoryView = keyboardToolbar

        lastNameTextField.inputAccessoryView = keyboardToolbar

        genderTextField.inputView = UIPickerView {
            $0.dataSource = self
            $0.delegate = self
        }
        genderTextField.inputAccessoryView = keyboardToolbar

        birthdayTextField.inputAccessoryView = keyboardToolbar
        birthdayTextField.inputView = UIDatePicker {
            $0.datePickerMode = .date
            $0.timeZone = TimeZone(secondsFromGMT: 0)
            $0.minimumDate = Calendar.current.date(byAdding: .year, value: -120, to: Date())
            $0.maximumDate = Date()
            $0.addTarget(self,
                         action: #selector(birthdayChanged(_:)),
                         for: .valueChanged)
        }

        show(location: false)

        passwordTextField.rightViewMode = .always
        passwordTextField.rightView = togglePasswordButton
        passwordTextField.inputAccessoryView = keyboardToolbar

        confirmPasswordTextField.rightViewMode = .always
        confirmPasswordTextField.rightView = toggleConfirmPasswordButton
        confirmPasswordTextField.inputAccessoryView = keyboardToolbar
    }

    var isLocationVisible: Bool {
        return locationTextField.superview != nil
    }

    func show(location visible: Bool) {
        guard let location = locationTextField,
              let country = countryTextField else { return }
        switch (visible, isLocationVisible) {
        case (true, false):
            let after = fieldsStack.arrangedSubviews.firstIndex(of: country) ?? 0
            fieldsStack.insertArrangedSubview(location, at: after + 1)
        case (false, true):
            fieldsStack.removeArrangedSubview(location)
            location.removeFromSuperview()
        default:
            break
        }
    }

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
        sender.login(vc: self) { [weak self] info in
            guard let self = self else { return }
            guard let info = info else {
                self.errorMessage = L.facebookFailed()
                self.performSegue(withIdentifier: Segues.presentSignupFail, sender: self)
                return
            }

            self.credentialsStack.removeArrangedSubview(self.facebookStack)
            self.facebookStack.removeFromSuperview()
            self.method = .facebook
            self.populate(with: info)
        }
    }

    @IBAction func toolbarBackTapped(_ sender: UIBarButtonItem) {
        if emailTextField.isEditing {
            emailTextField.resignFirstResponder()
            prepareRegister(showError: false)
        } else if firstNameTextField.isEditing {
            emailTextField.becomeFirstResponder()
        } else if lastNameTextField.isEditing {
            firstNameTextField.becomeFirstResponder()
        } else if genderTextField.isEditing {
            lastNameTextField.becomeFirstResponder()
        } else if countryTextField.isEditing {
            genderTextField.becomeFirstResponder()
        } else if locationTextField.isEditing {
            countryTextField.becomeFirstResponder()
        } else if birthdayTextField.isEditing {
            if isLocationVisible {
                locationTextField.becomeFirstResponder()
            } else {
                countryTextField.becomeFirstResponder()
            }
        } else if passwordTextField.isEditing {
            birthdayTextField.becomeFirstResponder()
        } else if confirmPasswordTextField.isEditing {
            passwordTextField.becomeFirstResponder()
        }
    }

    @IBAction func toolbarNextTapped(_ sender: UIBarButtonItem) {
        if emailTextField.isEditing {
            firstNameTextField.becomeFirstResponder()
        } else if firstNameTextField.isEditing {
            lastNameTextField.becomeFirstResponder()
        } else if lastNameTextField.isEditing {
            genderTextField.becomeFirstResponder()
        } else if genderTextField.isEditing {
            countryTextField.becomeFirstResponder()
        } else if countryTextField.isEditing {
            if isLocationVisible {
                locationTextField.becomeFirstResponder()
            } else {
                birthdayTextField.becomeFirstResponder()
            }
        } else if locationTextField.isEditing {
            birthdayTextField.becomeFirstResponder()
        } else if birthdayTextField.isEditing {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.isEditing {
            confirmPasswordTextField.becomeFirstResponder()
        } else if confirmPasswordTextField.isEditing {
            passwordTextField.becomeFirstResponder()
            prepareRegister(showError: false)
        }
    }

    @IBAction func toolbarClearTapped(_ sender: UIBarButtonItem) {
        if birthdayTextField.isEditing {
            birthdayTextField.text = nil
        }
        view.endEditing(true)
        prepareRegister(showError: false)
    }

    @IBAction func toolbarDoneTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        prepareRegister(showError: false)
    }

    @IBAction func unwindToSignup(segue: UIStoryboardSegue) {
        agreed = true
        termsOfServiceButton.setImage(R.image.checkmarkBlue(), for: .normal)
    }

    func populate(with payload: RegistrationPayload) {
        emailTextField.disable(text: payload.email)

        firstNameTextField.disable(text: payload.first_name)

        let gender: String
        switch payload.gender {
        case "M": gender = L.male()
        case "F": gender = L.female()
        case "U": gender = L.preferNot()
        default: gender = L.preferNot()
        }
        genderTextField.disable(text: gender)

        lastNameTextField.disable(text: payload.last_name)

        let birthday = payload.birthday ?? ""
        if !birthday.isEmpty {
            birthdayTextField.disable(text: birthday)
        }

        prepareRegister(showError: false)
    }

    @IBAction func birthdayChanged(_ sender: UIDatePicker) {
        birthdayTextField.text = DateFormatter.mtpDay.string(from: sender.date)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func prepareRegister(showError: Bool) {
        let email = emailTextField.text ?? ""
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let gender: String
        switch genderTextField.text?.first {
        case "M": gender = "M"
        case "F": gender = "F"
        default: gender = "U"
        }
        let birthday: String?
        if let text = birthdayTextField.text,
           !text.isEmpty {
            birthday = text
        } else {
            birthday = nil
        }
        let password = passwordTextField.text ?? ""
        let passwordConfirmation = confirmPasswordTextField.text ?? ""

        errorMessage = ""
        if !agreed {
            errorMessage = L.fixAgree()
        } else if !email.isValidEmail {
            errorMessage = L.fixEmail()
        } else if firstName.isEmpty {
            errorMessage = L.fixFirstName()
        } else if lastName.isEmpty {
            errorMessage = L.fixLastName()
        //} else if gender.isEmpty {
            //errorMessage = L.fixGender()
        //} else if birthday == nil {
            //errorMessage = L.fixBirthday()
        } else if !password.isValidPassword {
            errorMessage = L.fixPassword()
        } else if password != passwordConfirmation {
            errorMessage = L.fixConfirmPassword()
        //} else if country == nil {
            //errorMessage = L.fixCountry()
        } else if location == nil {
            if isLocationVisible {
                errorMessage = L.fixLocationProfile()
            } else if let country = country {
                location = data.get(location: country.countryId)
            }
        }
        guard //let country = country,
              //let location = location,
              errorMessage.isEmpty else {
            if showError {
                if errorMessage.isEmpty {
                    let operation = L.signUp()
                    errorMessage = L.unexpectedError(operation)
                }
                performSegue(withIdentifier: Segues.presentSignupFail, sender: self)
            }
            return
        }

        let payload = RegistrationPayload(
            birthday: birthday,
            country: country,
            firstName: firstName,
            email: email,
            gender: gender,
            lastName: lastName,
            location: location,
            password: password,
            passwordConfirmation: passwordConfirmation
        )

        register(payload: payload)
    }

    func register(payload: RegistrationPayload) {
        let operation = L.signUp()
        note.modal(info: L.signingUp())

        // swiftlint:disable:next closure_body_length
        net.userRegister(payload: payload) { [weak self, note] result in
            guard let self = self else { return note.dismissModal() }

            switch result {
            case .success(let user):
                note.modal(success: L.success())
                self.report.user(signIn: user.email, signUp: self.method)
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    note.dismissModal()
                    self?.performSegue(withIdentifier: Segues.showWelcome, sender: self)
                }
                return
            case .failure(.deviceOffline):
                self.errorMessage = L.deviceOfflineError(operation)
            case .failure(.serverOffline):
                self.errorMessage = L.serverOfflineError(operation)
            case .failure(.decoding):
                self.errorMessage = L.decodingError(operation)
            case .failure(.status(let code)):
                switch code {
                case 503:
                    self.errorMessage = L.serviceUnavailableError()
                default:
                    self.errorMessage = L.statusErrorReport(operation, code)
                }
            case .failure(.message(let message)):
                self.errorMessage = message
            case .failure(.network(let message)):
                self.errorMessage = L.networkError(operation, message)
            default:
                self.errorMessage = L.unexpectedError(operation)
            }
            note.dismissModal()
            self.performSegue(withIdentifier: Segues.presentSignupFail, sender: self)
        }
    }
}

// MARK: - UITextFieldDelegate

extension SignupVC: UITextFieldDelegate {

    /// Begin editing text field
    ///
    /// - Parameter textField: UITextField
    /// - Returns: Permission
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var clearHidden = true
        switch textField {
        case emailTextField:
            toolbarBackButton.isEnabled = false
            toolbarNextButton.isEnabled = true
        case confirmPasswordTextField:
            toolbarBackButton.isEnabled = true
            toolbarNextButton.isEnabled = false
        case countryTextField:
            performSegue(withIdentifier: Segues.showCountry, sender: self)
            return false
        case locationTextField:
            performSegue(withIdentifier: Segues.showLocation, sender: self)
            return false
        case birthdayTextField:
            clearHidden = false
            // swiftlint:disable:next fallthrough
            fallthrough
        default:
            toolbarBackButton.isEnabled = true
            toolbarNextButton.isEnabled = true
        }
        toolbarClearButton.isHidden = clearHidden

        return true
    }

    /// Handle return key
    ///
    /// - Parameter textField: UITextField
    /// - Returns: Permission
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            firstNameTextField.becomeFirstResponder()
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            genderTextField.becomeFirstResponder()
        case genderTextField:
            countryTextField.becomeFirstResponder()
        case countryTextField:
            if isLocationVisible {
                locationTextField.becomeFirstResponder()
            } else {
                birthdayTextField.becomeFirstResponder()
            }
        case locationTextField:
            birthdayTextField.becomeFirstResponder()
        case birthdayTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            confirmPasswordTextField.resignFirstResponder()
            prepareRegister(showError: false)
        default:
            break
        }
        return false
    }
}

// MARK: - UINavigationControllerDelegate

extension SignupVC: UINavigationControllerDelegate {

    /// Animation controller for navigation
    ///
    /// - Parameters:
    ///   - navigationController: Enclosing controller
    ///   - operation: Operation
    ///   - fromVC: source
    ///   - toVC: destination
    /// - Returns: Animator
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

// MARK: - LocationSearchDelegate

extension SignupVC: LocationSearchDelegate {

    /// Handle a location selection
    ///
    /// - Parameters:
    ///   - controller: source of selection
    ///   - item: Country or Location selected
    func locationSearch(controller: RealmSearchViewController,
                        didSelect item: Object) {
        switch item {
        case let countryItem as Country:
            guard country != countryItem else { return }
            if countryItem.countryId > 0 {
                country = countryItem
                countryTextField.text = countryItem.placeCountry
            } else {
                countryTextField.text = L.preferNot()
            }
            location = nil
            locationTextField.text = nil
            show(location: countryItem.hasChildren)
        case let locationItem as Location:
            guard location != locationItem else { return }
            location = locationItem
            locationTextField.text = locationItem.placeTitle
        default:
            log.error("unknown item type selected")
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension SignupVC: UIViewControllerTransitioningDelegate {

    /// Animation controller for transition
    ///
    /// - Parameters:
    ///   - presented: Presented controller
    ///   - presenting: Presenting controller
    ///   - source: Source controller
    /// - Returns: Animator
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ZoomAnimator()
    }

    /// Animation controller for dismissal
    ///
    /// - Parameter dismissed: View controller
    /// - Returns: Animator
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

// MARK: - UIPickerViewDataSource

extension SignupVC: UIPickerViewDataSource {

    /// Number of picker components
    ///
    /// - Parameter pickerView: Picker view
    /// - Returns: 1
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    /// Number of rows in picker component
    ///
    /// - Parameters:
    ///   - pickerView: Picker view
    ///   - component: Index
    /// - Returns: Value
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
}

// MARK: - UIPickerViewDelegate

extension SignupVC: UIPickerViewDelegate {

    /// Title of picker row
    ///
    /// - Parameters:
    ///   - pickerView: Picker view
    ///   - row: Index
    ///   - component: Index
    /// - Returns: Title
    public func pickerView(_ pickerView: UIPickerView,
                           titleForRow row: Int,
                           forComponent component: Int) -> String? {
        return genders[row]
    }

    /// Handle picker selection
    ///
    /// - Parameters:
    ///   - pickerView: Picker view
    ///   - row: Index
    ///   - component: Index
    public func pickerView(_ pickerView: UIPickerView,
                           didSelectRow row: Int,
                           inComponent component: Int) {
        guard row > 0 else { return }
        genderTextField.text = genders[row]
        genderTextField.resignFirstResponder()
    }
}

// MARK: - Exposing

extension SignupVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        let items = navigationItem.leftBarButtonItems
        UISignup.close.expose(item: items?.first)

        UISignup.birthday.expose(item: birthdayTextField)
        UISignup.confirm.expose(item: confirmPasswordTextField)
        UISignup.country.expose(item: countryTextField)
        UISignup.credentials.expose(item: credentialsStack)
        UISignup.email.expose(item: emailTextField)
        UISignup.facebook.expose(item: facebookButton)
        UISignup.first.expose(item: firstNameTextField)
        UISignup.gender.expose(item: genderTextField)
        UISignup.last.expose(item: lastNameTextField)
        UISignup.login.expose(item: loginButton)
        UISignup.country.expose(item: countryTextField)
        UISignup.location.expose(item: locationTextField)
        UISignup.password.expose(item: passwordTextField)
        UISignup.signup.expose(item: signupButton)
        UISignup.toggleConfirm.expose(item: toggleConfirmPasswordButton)
        UISignup.togglePassword.expose(item: togglePasswordButton)
        UISignup.tos.expose(item: termsOfServiceButton)

        UIKeyboard.toolbar.expose(item: keyboardToolbar)
        UIKeyboard.back.expose(item: toolbarBackButton)
        UIKeyboard.clear.expose(item: toolbarClearButton)
        UIKeyboard.done.expose(item: toolbarDoneButton)
        UIKeyboard.next.expose(item: toolbarNextButton)
    }
}

// MARK: - InterfaceBuildable

extension SignupVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        birthdayTextField.require()
        confirmPasswordTextField.require()
        countryTextField.require()
        credentialsStack.require()
        emailTextField.require()
        facebookButton.require()
        facebookStack.require()
        fieldsStack.require()
        firstNameTextField.require()
        genderTextField.require()
        keyboardToolbar.require()
        lastNameTextField.require()
        locationTextField.require()
        loginButton.require()
        passwordTextField.require()
        scrollView.require()
        signupButton.require()
        termsOfServiceButton.require()
        toggleConfirmPasswordButton.require()
        togglePasswordButton.require()
        toolbarBackButton.require()
        toolbarClearButton.require()
        toolbarDoneButton.require()
        toolbarNextButton.require()
    }
}
