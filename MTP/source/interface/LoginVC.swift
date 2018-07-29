// @copyright Trollwerks Inc.

import FacebookLogin
import UIKit

final class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        loginButton.center = view.center
        view.addSubview(loginButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        if R.segue.loginVC.unwindFromLogin(segue: segue) != nil {
            log.verbose(segue.name)
        } else {
            log.warning("Unexpected segue: \(segue.name)")
        }
    }
}
