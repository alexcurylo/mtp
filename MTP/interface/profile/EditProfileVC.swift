// @copyright Trollwerks Inc.

import KRProgressHUD

final class EditProfileVC: UITableViewController, ServiceProvider {

    typealias Segues = R.segue.editProfileVC

    @IBOutlet private var backgroundView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundView = backgroundView
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
        log.verbose("prepare for \(segue.name)")
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

// MARK: - Actions

private extension EditProfileVC {

    func saveEdits() {
        log.todo("implement saveEdits")
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
