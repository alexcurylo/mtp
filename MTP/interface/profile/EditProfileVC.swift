// @copyright Trollwerks Inc.

import UIKit

final class EditProfileVC: UITableViewController {

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
            gestalt.logOut()
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
        log.info("TO DO: MTPAPI.implement saveEdits")
    }

    @IBAction func deleteAccount(segue: UIStoryboardSegue) {
        MTPAPI.deleteAccount { [weak self] result in
            switch result {
            case .success:
                self?.performSegue(withIdentifier: R.segue.editProfileVC.unwindFromEditProfile, sender: self)
            case .failure(let error):
                log.error("TO DO: handle error calling /deleteAccount: \(String(describing: error))")
            }
        }
    }
}
