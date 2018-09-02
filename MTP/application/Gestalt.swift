// @copyright Trollwerks Inc.

import UIKit

var gestalt = UserDefaults.standard

protocol Gestalt {

    var email: String { get set }
    var name: String { get set }
    var password: String { get set }
    var user: User? { get set }
}

extension Gestalt {

    mutating func logOut() {
        FacebookButton.logOut()
        email = ""
        name = ""
        password = ""
        user = nil
    }

    var isLoggedIn: Bool {
        guard let token = user?.token else { return false }
        return !token.isEmpty
    }
}
