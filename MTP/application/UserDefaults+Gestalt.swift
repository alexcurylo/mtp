// @copyright Trollwerks Inc.

import Foundation

extension UserDefaults: Gestalt {

    var email: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }

    var lastUserRefresh: Date? {
        get { return date(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }

    var locations: [Location] {
        get {
            do {
                return try get(objectType: [Location].self, forKey: #function) ?? []
            } catch {
                log.error("decoding locations value: \(error)")
                return []
            }
        }
        set {
            do {
                return try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding locations newValue: \(error)")
            }
        }
    }

    var name: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }

    var password: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }

    var rankingsFilter: UserFilter? {
        get {
            do {
                return try get(objectType: UserFilter.self, forKey: #function)
            } catch {
                log.error("decoding rankingsFilter value: \(error)")
                return nil
            }
        }
        set {
            guard let newRankingsFilter = newValue else {
                set(nil, forKey: #function)
                return
            }
            do {
                return try set(object: newRankingsFilter, forKey: #function)
            } catch {
                log.error("encoding rankingsFilter newValue: \(error)")
            }
        }
    }

    var token: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }

    var user: User? {
        get {
            do {
                return try get(objectType: User.self, forKey: #function)
            } catch {
                log.error("decoding user value: \(error)")
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
                log.error("encoding user newValue: \(error)")
            }
        }
    }
}
