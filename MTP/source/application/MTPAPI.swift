// @copyright Trollwerks Inc.

import Foundation

enum MTPAPI {

    static func login(name: String,
                      email: String,
                      then: (Bool) -> Void) {
        guard !name.isEmpty && !email.isEmpty else {
            log.verbose("MTPAPI.login attempt invalid: name `\(name)` email `\(email)`")
            return
        }

        log.info("TO DO: implement MTPAPI.login: \(name), \(email)")
        then(true)
    }

    static func register(name: String,
                         email: String,
                         then: (Bool) -> Void) {
        guard !name.isEmpty && !email.isEmpty else {
            log.verbose("MTPAPI.register attempt invalid: name `\(name)` email `\(email)`")
            return
        }

        log.info("TO DO: implement MTPAPI.register: \(name), \(email)")
        then(true)
    }
}
