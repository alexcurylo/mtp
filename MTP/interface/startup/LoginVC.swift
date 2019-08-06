// @copyright Trollwerks Inc.

import UIKit

/// Handle the user login process
final class LoginVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.loginVC

    @IBOutlet private var emailTextField: InsetTextField?
    @IBOutlet private var passwordTextField: InsetTextField?
    @IBOutlet private var togglePasswordButton: UIButton?

    @IBOutlet private var keyboardToolbar: UIToolbar?
    @IBOutlet private var toolbarBackButton: UIBarButtonItem?
    @IBOutlet private var toolbarNextButton: UIBarButtonItem?

    private var errorMessage: String = ""

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        emailTextField?.inputAccessoryView = keyboardToolbar

        passwordTextField?.rightViewMode = .always
        passwordTextField?.rightView = togglePasswordButton
        passwordTextField?.inputAccessoryView = keyboardToolbar
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .login)
        navigationController?.delegate = self

        emailTextField?.text = data.email
    }

    /// Prepare for hide
    ///
    /// - Parameter animated: Whether animating
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.delegate = nil

        data.email = emailTextField?.text ?? ""
   }

    /// Allow navigation
    ///
    /// - Parameters:
    ///   - identifier: Segue identifier
    ///   - sender: Action originator
    /// - Returns: Permission
    override func shouldPerformSegue(withIdentifier identifier: String,
                                     sender: Any?) -> Bool {
        switch identifier {
        case Segues.presentForgotPassword.identifier:
            guard let email = emailTextField?.text, email.isValidEmail else {
                errorMessage = L.fixEmail()
                performSegue(withIdentifier: Segues.presentLoginFail, sender: self)
                return false
            }
            return true
        default:
            return true
        }
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        view.endEditing(true)
        switch segue.identifier {
        case Segues.presentLoginFail.identifier:
            let alert = Segues.presentLoginFail(segue: segue)
            alert?.destination.inject(model: errorMessage)
            hide(navBar: true)
            data.email = emailTextField?.text ?? ""
        case Segues.presentForgotPassword.identifier:
            hide(navBar: true)
            data.email = emailTextField?.text ?? ""
        case Segues.showMain.identifier:
            let main = Segues.showMain(segue: segue)
            main?.destination.inject(model: .locations)
        case Segues.switchSignup.identifier,
             Segues.unwindFromLogin.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - Private

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
        sender.login(vc: self) { [weak self] info in
            self?.emailTextField?.text = info?.email
            // currently not implemented: login with Facebook ID
        }
    }

    @IBAction func toolbarBackTapped(_ sender: UIBarButtonItem) {
        if emailTextField?.isEditing ?? false {
            emailTextField?.resignFirstResponder()
            prepareLogin(showError: false)
        } else if passwordTextField?.isEditing ?? false {
            emailTextField?.becomeFirstResponder()
        }
    }

    @IBAction func toolbarNextTapped(_ sender: UIBarButtonItem) {
        if emailTextField?.isEditing ?? false {
            passwordTextField?.becomeFirstResponder()
        } else if passwordTextField?.isEditing ?? false {
            passwordTextField?.resignFirstResponder()
            prepareLogin(showError: false)
        }
    }

    @IBAction func toolbarDoneTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        prepareLogin(showError: false)
   }

    func prepareLogin(showError: Bool) {
        let email = emailTextField?.text ?? ""
        let password = passwordTextField?.text ?? ""
        if !email.isValidEmail {
            errorMessage = L.fixEmail()
        } else if password.isEmpty {
            errorMessage = L.enterPassword()
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
        let operation = L.logIn()
        note.modal(info: L.loggingIn())

        net.userLogin(email: email,
                      // swiftlint:disable:next closure_body_length
                      password: password) { [weak self, note] result in
            switch result {
            case .success:
                note.modal(success: L.success())
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    note.dismissModal()
                    self?.performSegue(withIdentifier: Segues.showMain, sender: self)
                }
                return
            case .failure(.deviceOffline):
                self?.errorMessage = L.deviceOfflineError(operation)
            case .failure(.serverOffline):
                self?.errorMessage = L.serverOfflineError(operation)
            case .failure(.decoding):
                self?.errorMessage = L.decodingError(operation)
            case .failure(.status):
                self?.errorMessage = L.statusError(operation)
            case .failure(.message(let message)):
                self?.errorMessage = message
            case .failure(.network(let message)):
                self?.errorMessage = L.networkError(operation, message)
            default:
                self?.errorMessage = L.unexpectedError(operation)
            }
            note.dismissModal()
            self?.performSegue(withIdentifier: Segues.presentLoginFail, sender: self)
        }
    }
}

// MARK: - UITextFieldDelegate

extension LoginVC: UITextFieldDelegate {

    /// Begin editing text field
    ///
    /// - Parameter textField: UITextField
    /// - Returns: Permission
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            toolbarBackButton?.isEnabled = false
            toolbarNextButton?.isEnabled = true
        case passwordTextField:
            toolbarBackButton?.isEnabled = true
            toolbarNextButton?.isEnabled = false
        default:
            toolbarBackButton?.isEnabled = true
            toolbarNextButton?.isEnabled = true
        }
        return true
    }

    /// Handle return key
    ///
    /// - Parameter textField: UITextField
    /// - Returns: Permission
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

// MARK: - UINavigationControllerDelegate

extension LoginVC: UINavigationControllerDelegate {

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
        if toVC is SignupVC {
            return FadeInAnimator()
        }
        return nil
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension LoginVC: UIViewControllerTransitioningDelegate {

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

// MARK: - Injectable

extension LoginVC: Injectable {

    /// Injected dependencies
    typealias Model = ()

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        emailTextField.require()
        passwordTextField.require()
        togglePasswordButton.require()
        keyboardToolbar.require()
        toolbarBackButton.require()
        toolbarNextButton.require()
    }
}
