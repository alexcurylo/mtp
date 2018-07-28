// @copyright Trollwerks Inc.

import UIKit

// https://developers.facebook.com/docs/swift/login
/*
import FacebookLogin
func viewDidLoad() {
    let loginButton = LoginButton(readPermissions: [ .publicProfile ])
    loginButton.center = view.center
    
    view.addSubview(loginButton)
}
 // Extend the code sample "1. Add Facebook Login Button Code"
 // In your viewDidLoad method:
 loginButton = LoginButton(readPermissions: [ .publicProfile, .Email, .UserFriends ])
 
*/

final class LoginVC: UIViewController {

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
        if R.segue.loginVC.unwindFromLogin(segue: segue) != nil {
            log.verbose("showMain")
        } else {
            log.warning("Unexpected segue: \(String(describing: segue.identifier))")
        }
    }
}
