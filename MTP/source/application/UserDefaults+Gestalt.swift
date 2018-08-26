// @copyright Trollwerks Inc.

import Foundation

extension UserDefaults: Gestalt {

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

    var user: User? {
        get {
            do {
                return try get(objectType: User.self, forKey: #function)
            } catch {
                log.error("Decoding user value: \(error)")
                return nil
            }
        }
        set {
            guard let newUser = newValue else {
                set(nil, forKey: #function)
                return
            }
            do {
                return try set(object: newUser, forKey: #function)
            } catch {
                log.error("Encoding user newValue: \(error)")
            }
        }
    }
}
