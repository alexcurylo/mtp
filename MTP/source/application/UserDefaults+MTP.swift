// @copyright Trollwerks Inc.

import Foundation

extension UserDefaults {

    func logOut() {
        email = ""
        name = ""
    }

    var isLoggedIn: Bool {
        return !email.isEmpty && !name.isEmpty
    }

    var email: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }

    var name: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }
}
