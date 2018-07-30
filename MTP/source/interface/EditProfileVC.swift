// @copyright Trollwerks Inc.

import FacebookLogin
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
        log.warning("Unexpected segue: \(segue.name)")
    }
}

// MARK: - Actions

private extension EditProfileVC {

    @IBAction func logOut() {
        LoginManager().logOut()
        performSegue(withIdentifier: R.segue.editProfileVC.unwindFromEditProfile, sender: self)
    }

    @IBAction func deleteAccount() {
        log.debug("TO DO: implement deleteAccountpr")
    }
}
