// @copyright Trollwerks Inc.

import RealmSwift
import UIKit

// swiftlint:disable file_length

final class SignupVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.signupVC

    @IBOutlet private var scrollView: UIScrollView?
    @IBOutlet private var credentialsStack: UIStackView?
    @IBOutlet private var facebookStack: UIStackView?
    @IBOutlet private var fieldsStack: UIStackView?

    @IBOutlet private var emailTextField: InsetTextField?
    @IBOutlet private var firstNameTextField: InsetTextField?
    @IBOutlet private var lastNameTextField: InsetTextField?
    @IBOutlet private var genderTextField: InsetTextField?
    @IBOutlet private var countryTextField: InsetTextField?
    @IBOutlet private var locationTextField: InsetTextField?
    @IBOutlet private var birthdayTextField: InsetTextField?
    @IBOutlet private var passwordTextField: InsetTextField?
    @IBOutlet private var togglePasswordButton: UIButton?
    @IBOutlet private var confirmPasswordTextField: InsetTextField?
    @IBOutlet private var toggleConfirmPasswordButton: UIButton?

    @IBOutlet private var keyboardToolbar: UIToolbar?
    @IBOutlet private var toolbarBackButton: UIBarButtonItem?
    @IBOutlet private var toolbarNextButton: UIBarButtonItem?

    private var errorMessage: String = ""

    private var country: Country?
    private var location: Location?

    private let genders = [Localized.selectGender(), Localized.male(), Localized.female()]

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        setupView()
        startKeyboardListening()
   }

    deinit {
        stopKeyboardListening()
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
        view.endEditing(true)
        switch segue.identifier {
        case Segues.presentSignupFail.identifier:
            let alert = Segues.presentSignupFail(segue: segue)
            alert?.destination.errorMessage = errorMessage
            hide(navBar: true)
        case Segues.showCountry.identifier:
            if let destination = Segues.showCountry(segue: segue)?.destination.topViewController as? LocationSearchVC {
                destination.set(list: .country,
                                styler: .login,
                                delegate: self)
            }
        case Segues.showLocation.identifier:
            if let destination = Segues.showLocation(segue: segue)?.destination.topViewController as? LocationSearchVC {
                let countryId = country?.countryId
                destination.set(list: .location(country: countryId),
                                styler: .login,
                                delegate: self)
            }
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

// MARK: - KeyboardListener

extension SignupVC: KeyboardListener {

    var keyboardScrollee: UIScrollView? { return scrollView }
}

// MARK: - SignupVC

private extension SignupVC {

    func setupView() {
        emailTextField?.text = data.email
        emailTextField?.inputAccessoryView = keyboardToolbar

        firstNameTextField?.inputAccessoryView = keyboardToolbar

        lastNameTextField?.inputAccessoryView = keyboardToolbar

        genderTextField?.inputView = UIPickerView {
            $0.dataSource = self
            $0.delegate = self
        }
        genderTextField?.inputAccessoryView = keyboardToolbar

        birthdayTextField?.inputView = UIDatePicker {
            $0.datePickerMode = .date
            $0.maximumDate = Date()
            $0.minimumDate = Calendar.current.date(byAdding: .year, value: -120, to: Date())
            $0.addTarget(self,
                         action: #selector(birthdayChanged(_:)),
                         for: .valueChanged)
        }
        birthdayTextField?.inputAccessoryView = keyboardToolbar

        show(location: false)

        passwordTextField?.rightViewMode = .always
        passwordTextField?.rightView = togglePasswordButton
        passwordTextField?.inputAccessoryView = keyboardToolbar

        confirmPasswordTextField?.rightViewMode = .always
        confirmPasswordTextField?.rightView = toggleConfirmPasswordButton
        confirmPasswordTextField?.inputAccessoryView = keyboardToolbar
    }

    var isLocationVisible: Bool {
        return locationTextField?.superview != nil
    }

    func show(location visible: Bool) {
        guard let location = locationTextField,
              let stack = fieldsStack,
              let country = countryTextField else { return }
        switch (visible, isLocationVisible) {
        case (true, false):
            let after = stack.arrangedSubviews.firstIndex(of: country) ?? 0
            stack.insertArrangedSubview(location, at: after + 1)
        case (false, true):
            stack.removeArrangedSubview(location)
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
                self.errorMessage = Localized.facebookFailed()
                self.performSegue(withIdentifier: Segues.presentSignupFail, sender: self)
                return
            }

            if let stack = self.credentialsStack,
                let fbStack = self.facebookStack {
                stack.removeArrangedSubview(fbStack)
                fbStack.removeFromSuperview()
            }

            self.populate(with: info)
        }
    }

    @IBAction func toolbarBackTapped(_ sender: UIBarButtonItem) {
        if emailTextField?.isEditing ?? false {
            emailTextField?.resignFirstResponder()
            prepareRegister(showError: false)
        } else if firstNameTextField?.isEditing ?? false {
            emailTextField?.becomeFirstResponder()
        } else if lastNameTextField?.isEditing ?? false {
            firstNameTextField?.becomeFirstResponder()
        } else if genderTextField?.isEditing ?? false {
            lastNameTextField?.becomeFirstResponder()
        } else if countryTextField?.isEditing ?? false {
            genderTextField?.becomeFirstResponder()
        } else if locationTextField?.isEditing ?? false {
            countryTextField?.becomeFirstResponder()
        } else if birthdayTextField?.isEditing ?? false {
            if isLocationVisible {
                locationTextField?.becomeFirstResponder()
            } else {
                countryTextField?.becomeFirstResponder()
            }
        } else if passwordTextField?.isEditing ?? false {
            birthdayTextField?.becomeFirstResponder()
        } else if confirmPasswordTextField?.isEditing ?? false {
            passwordTextField?.becomeFirstResponder()
        }
    }

    @IBAction func toolbarNextTapped(_ sender: UIBarButtonItem) {
        if emailTextField?.isEditing ?? false {
            firstNameTextField?.becomeFirstResponder()
        } else if firstNameTextField?.isEditing ?? false {
            lastNameTextField?.becomeFirstResponder()
        } else if lastNameTextField?.isEditing ?? false {
            genderTextField?.becomeFirstResponder()
        } else if genderTextField?.isEditing ?? false {
            countryTextField?.becomeFirstResponder()
        } else if countryTextField?.isEditing ?? false {
            if isLocationVisible {
                locationTextField?.becomeFirstResponder()
            } else {
                birthdayTextField?.becomeFirstResponder()
            }
        } else if locationTextField?.isEditing ?? false {
            birthdayTextField?.becomeFirstResponder()
        } else if birthdayTextField?.isEditing ?? false {
            passwordTextField?.becomeFirstResponder()
        } else if passwordTextField?.isEditing ?? false {
            confirmPasswordTextField?.becomeFirstResponder()
        } else if confirmPasswordTextField?.isEditing ?? false {
            passwordTextField?.becomeFirstResponder()
            prepareRegister(showError: false)
        }
    }

    @IBAction func toolbarDoneTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        prepareRegister(showError: false)
    }

    func populate(with info: RegistrationInfo) {
        emailTextField?.disable(text: info.email)

        firstNameTextField?.disable(text: info.first_name)

        let gender: String
        switch info.gender {
        case "M": gender = Localized.male()
        case "F": gender = Localized.female()
        default: gender = ""
        }
        genderTextField?.disable(text: gender)

        lastNameTextField?.disable(text: info.last_name)

        if info.birthday != Date.distantFuture {
            let birthday = DateFormatter.mtpDay.string(from: info.birthday)
            birthdayTextField?.disable(text: birthday)
        }

        prepareRegister(showError: false)
    }

    @IBAction func birthdayChanged(_ sender: UIDatePicker) {
        birthdayTextField?.text = DateFormatter.mtpDay.string(from: sender.date)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
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
        let birthdayText = birthdayTextField?.text ?? ""
        let birthdayDate = DateFormatter.mtpDay.date(from: birthdayText)
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
        } else if country == nil {
            errorMessage = Localized.fixCountry()
        } else if location == nil {
            if isLocationVisible {
                errorMessage = Localized.fixLocation()
            } else {
                location = data.get(location: country?.countryId ?? 0)
            }
        } else if birthdayDate == nil {
            errorMessage = Localized.fixBirthday()
        } else if !password.isValidPassword {
            errorMessage = Localized.fixPassword()
        } else if password != passwordConfirmation {
            errorMessage = Localized.fixConfirmPassword()
        } else {
            errorMessage = ""
        }
        guard let birthday = birthdayDate,
              let country = country,
              let location = location,
              errorMessage.isEmpty else {
            if showError {
                if errorMessage.isEmpty {
                    errorMessage = Localized.unexpectedError()
                }
                performSegue(withIdentifier: Segues.presentSignupFail, sender: self)
            }
            return
        }

        let info = RegistrationInfo(
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

        register(info: info)
    }

    func register(info: RegistrationInfo) {
        note.modal(info: Localized.signingUp())
        mtp.userRegister(info: info) { [weak self, note] result in
            switch result {
            case .success:
                note.modal(success: Localized.success())
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    note.dismissModal()
                    self?.performSegue(withIdentifier: Segues.showWelcome, sender: self)
                }
                return
            case .failure(.status),
                 .failure(.results):
                self?.errorMessage = Localized.resultError()
            case .failure(.message(let message)):
                self?.errorMessage = message
            case .failure(.network(let message)):
                self?.errorMessage = Localized.networkError(message)
            default:
                self?.errorMessage = Localized.unexpectedError()
            }
            note.dismissModal()
            self?.performSegue(withIdentifier: Segues.presentSignupFail, sender: self)
        }
    }
}

// MARK: - UITextFieldDelegate

extension SignupVC: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            toolbarBackButton?.isEnabled = false
            toolbarNextButton?.isEnabled = true
        case confirmPasswordTextField:
            toolbarBackButton?.isEnabled = true
            toolbarNextButton?.isEnabled = false
        case countryTextField:
            performSegue(withIdentifier: Segues.showCountry, sender: self)
            return false
        case locationTextField:
            performSegue(withIdentifier: Segues.showLocation, sender: self)
            return false
        default:
            toolbarBackButton?.isEnabled = true
            toolbarNextButton?.isEnabled = true
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            firstNameTextField?.becomeFirstResponder()
        case firstNameTextField:
            lastNameTextField?.becomeFirstResponder()
        case lastNameTextField:
            genderTextField?.becomeFirstResponder()
        case genderTextField:
            countryTextField?.becomeFirstResponder()
        case countryTextField:
            if isLocationVisible {
                locationTextField?.becomeFirstResponder()
            } else {
                birthdayTextField?.becomeFirstResponder()
            }
        case locationTextField:
            birthdayTextField?.becomeFirstResponder()
        case birthdayTextField:
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

// MARK: - UINavigationControllerDelegate

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

// MARK: - LocationSearchDelegate

extension SignupVC: LocationSearchDelegate {

    func locationSearch(controller: RealmSearchViewController,
                        didSelect item: Object) {
        switch item {
        case let countryItem as Country:
            guard country != countryItem else { return }
            country = countryItem
            countryTextField?.text = countryItem.countryName
            location = nil
            locationTextField?.text = nil
            show(location: countryItem.hasChildren)
        case let locationItem as Location:
            guard location != locationItem else { return }
            location = locationItem
            locationTextField?.text = locationItem.locationName
        default:
            log.error("unknown item type selected")
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate

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

// MARK: - UIPickerViewDataSource

extension SignupVC: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
}

// MARK: - UIPickerViewDelegate

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

// MARK: - Injectable

extension SignupVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    func requireInjections() {
        scrollView.require()
        credentialsStack.require()
        facebookStack.require()
        fieldsStack.require()
        emailTextField.require()
        firstNameTextField.require()
        lastNameTextField.require()
        genderTextField.require()
        countryTextField.require()
        locationTextField.require()
        birthdayTextField.require()
        passwordTextField.require()
        togglePasswordButton.require()
        confirmPasswordTextField.require()
        toggleConfirmPasswordButton.require()
        keyboardToolbar.require()
        toolbarBackButton.require()
        toolbarNextButton.require()
    }
}
