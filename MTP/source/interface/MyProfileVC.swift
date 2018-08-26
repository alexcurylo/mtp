// @copyright Trollwerks Inc.

import UIKit

final class MyProfileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        style.standard.apply()
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        case R.segue.myProfileVC.directEdit.identifier,
             R.segue.myProfileVC.showEditProfile.identifier,
             R.segue.myProfileVC.showSettings.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}
