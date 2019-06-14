// @copyright Trollwerks Inc.

import KRProgressHUD

final class EditProfileVC: UITableViewController, ServiceProvider {

    private typealias Segues = R.segue.editProfileVC

    @IBOutlet private var saveButton: UIBarButtonItem?

    @IBOutlet private var backgroundView: UIView?

    @IBOutlet private var avatarButton: UIButton?
    @IBOutlet private var firstNameTextField: UITextField?
    @IBOutlet private var lastNameTextField: UITextField?
    @IBOutlet private var birthdayTextField: UITextField?
    @IBOutlet private var genderTextField: UITextField?
    @IBOutlet private var countryTextField: UITextField?
    @IBOutlet private var locationTextField: UITextField?
    @IBOutlet private var emailTextField: UITextField?
    @IBOutlet private var aboutTextView: UITextView?
    @IBOutlet private var airportTextField: UITextField?

    @IBOutlet private var linksStack: UIStackView?
    @IBOutlet private var linksTitle: UILabel?
    @IBOutlet private var addLinkButton: UIButton?

    @IBOutlet private var contactDisplayButton: UIButton?
    @IBOutlet private var contactDontDisplayButton: UIButton?
    @IBOutlet private var contactNoneButton: UIButton?

    private var original: UserJSON?
    private var current: UserJSON?

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        tableView.backgroundView = backgroundView

        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.saveEdits.identifier:
            saveEdits()
        case Segues.unwindFromEditProfile.identifier:
            data.logOut()
        case Segues.cancelEdits.identifier,
             Segues.showConfirmDelete.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - UITableViewDelegate

extension EditProfileVC {

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Private

private extension EditProfileVC {

    func configure() {
        let user = data.user
        original = user
        current = user
        saveButton?.isEnabled = false
    }

    func updateSave() {
        saveButton?.isEnabled = original != current
    }

    func saveEdits() {
        guard let original = original,
              let current = current,
              current != original else { return }

        data.user = current
        // log.todo("handle update feedback")
        mtp.userUpdate(info: current) { _ in }
    }

    @IBAction func avatarTapped(_ sender: UIButton) {
        log.todo("avatarTapped")
    }

    @IBAction func deleteLinkTapped(_ sender: UIButton) {
        log.todo("deleteLinkTapped")
    }

    @IBAction func addLinkTapped(_ sender: UIButton) {
        log.todo("addLinkTapped")
    }

    @IBAction func contactDisplayTapped(_ sender: UIButton) {
        log.todo("contactDisplayTapped")
    }

    @IBAction func contactDontDisplayTapped(_ sender: UIButton) {
        log.todo("contactDontDisplayTapped")
    }

    @IBAction func contactNoneTapped(_ sender: UIButton) {
        log.todo("contactNoneTapped")
    }

    @IBAction func deleteAccount(segue: UIStoryboardSegue) {
        KRProgressHUD.show(withMessage: Localized.deletingAccount())
        mtp.userDeleteAccount { [weak self] result in
            let errorMessage: String
            switch result {
            case .success:
                KRProgressHUD.showSuccess(withMessage: Localized.success())
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    KRProgressHUD.dismiss()
                    self?.performSegue(withIdentifier: Segues.unwindFromEditProfile, sender: self)
                }
                return
            case .failure(.status),
                 .failure(.results):
                errorMessage = Localized.resultError()
            case .failure(.message(let message)):
                errorMessage = message
            case .failure(.network(let message)):
                errorMessage = Localized.networkError(message)
            default:
                errorMessage = Localized.unexpectedError()
            }
            KRProgressHUD.showError(withMessage: errorMessage)
            DispatchQueue.main.asyncAfter(deadline: .medium) {
                KRProgressHUD.dismiss()
            }
        }
    }
}

extension EditProfileVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    func requireInjections() {
        saveButton.require()
        backgroundView.require()
        firstNameTextField.require()
        lastNameTextField.require()
        birthdayTextField.require()
        genderTextField.require()
        countryTextField.require()
        locationTextField.require()
        emailTextField.require()
        aboutTextView.require()
        airportTextField.require()
        linksStack.require()
        linksTitle.require()
        addLinkButton.require()
        contactDisplayButton.require()
        contactDontDisplayButton.require()
        contactNoneButton.require()
    }
}
