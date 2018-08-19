// @copyright Trollwerks Inc.

import Foundation

extension UserDefaults {

    func logOut() {
        email = ""
        name = ""
        password = ""
        token = ""
    }

    var isLoggedIn: Bool {
        return !token.isEmpty
    }

    var email: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }

    var name: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }

    var password: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }

    var token: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }
}
