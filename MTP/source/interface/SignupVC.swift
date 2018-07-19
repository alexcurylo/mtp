// @copyright Trollwerks Inc.

import UIKit

final class SignupVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if R.segue.signupVC.unwindFromSignup(segue: segue) != nil {
            log.verbose("unwindFromSignup")
        } else {
            log.warning("Unexpected segue: \(String(describing: segue.identifier))")
        }
    }
}
