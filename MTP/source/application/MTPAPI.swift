// @copyright Trollwerks Inc.

import Foundation

enum MTPAPI {

    static func login(email: String,
                      password: String,
                      then: (Bool) -> Void) {
        guard !email.isEmpty && !password.isEmpty else {
            log.verbose("login attempt invalid: email `\(email)` password `\(password)`")
            return
        }

        log.info("TO DO: implement MTPAPI.login: \(email), \(password)")
        then(true)
    }

    static func register(name: String,
                         email: String,
                         password: String,
                         then: (Bool) -> Void) {
        guard !name.isEmpty && !email.isEmpty && !password.isEmpty else {
            log.verbose("register attempt invalid: name `\(name)` email `\(email)` password `\(password)`")
            return
        }

        log.info("TO DO: implement MTPAPI.register: \(name), \(email), \(password)")
        then(true)
    }
}
