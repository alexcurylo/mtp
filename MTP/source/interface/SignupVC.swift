// @copyright Trollwerks Inc.

import UIKit

final class SignupVC: UIViewController {

    @IBOutlet private weak var nameTextField: UITextField?
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
        log.info("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch true {
        case R.segue.signupVC.unwindFromSignup(segue: segue) != nil,
             R.segue.signupVC.switchLogin(segue: segue) != nil,
             R.segue.signupVC.pushTermsOfService(segue: segue) != nil,
             R.segue.signupVC.showWelcome(segue: segue) != nil:
            log.verbose(segue.name)
        default:
            log.warning("Unexpected segue: \(segue.name)")
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
        register(name: nameTextField?.text ?? "",
                 email: emailTextField?.text ?? "",
                 password: passwordTextField?.text ?? "")
    }

    @IBAction func facebookTapped(_ sender: FacebookButton) {
        sender.login { [weak self] name, email, id in
            self?.register(name: name, email: email, password: id)
        }
    }

    func register(name: String, email: String, password: String) {
        MTPAPI.register(name: name, email: email, password: password) { [weak self] success in
            if success {
                self?.performSegue(withIdentifier: R.segue.signupVC.showWelcome, sender: self)
            } else {
                log.warning("implement register fail notification")
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
