// @copyright Trollwerks Inc.

import UIKit

final class EditProfileVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.info("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch true {
        case R.segue.editProfileVC.unwindFromEditProfile(segue: segue) != nil:
            log.verbose(segue.name)
        default:
            log.warning("Unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - Actions

private extension EditProfileVC {

    @IBAction func logOut() {
        FacebookButton.logOut()
        UserDefaults.standard.logOut()
        performSegue(withIdentifier: R.segue.editProfileVC.unwindFromEditProfile, sender: self)
    }

    @IBAction func deleteAccount() {
        log.debug("TO DO: implement deleteAccount")
    }
}