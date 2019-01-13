// @copyright Trollwerks Inc.

import JWTDecode
import UIKit

var gestalt = UserDefaults.standard

protocol Gestalt {

    var email: String { get set }
    var lastUserRefresh: Date? { get set }
    var locations: [Location] { get set }
    var name: String { get set }
    var password: String { get set }
    var rankingsFilter: UserFilter? { get set }
    var token: String { get set }
    var user: User? { get set }
}

extension Gestalt {

    mutating func logOut() {
        FacebookButton.logOut()
        email = ""
        token = ""
        name = ""
        password = ""
        user = nil
    }

    var isLoggedIn: Bool {
        guard !token.isEmpty,
              let jwt = try? decode(jwt: token),
              let expiry = jwt.expiresAt else { return false }
        // https://github.com/auth0/JWTDecode.swift/issues/70
        let expired = expiry > Date().toUTC
        if expired {
            log.debug("token expired -- should we be refreshing somehow?")
        }
        return expired
    }
}
