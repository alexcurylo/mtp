// @copyright Trollwerks Inc.

import KRProgressHUD

final class EditProfileVC: UITableViewController, ServiceProvider {

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
        case R.segue.editProfileVC.saveEdits.identifier:
            saveEdits()
        case R.segue.editProfileVC.unwindFromEditProfile.identifier:
            data.logOut()
        case R.segue.editProfileVC.cancelEdits.identifier,
             R.segue.editProfileVC.showConfirmDelete.identifier:
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
                    self?.performSegue(withIdentifier: R.segue.editProfileVC.unwindFromEditProfile, sender: self)
                }
                return
            case .failure(.status),
                 .failure(.results):
                errorMessage = Localized.resultError()
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
