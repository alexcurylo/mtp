// @copyright Trollwerks Inc.

import Foundation

extension UserDefaults: Gestalt {

    var beaches: [Beach] {
        get {
            do {
                return try get(objectType: [Beach].self, forKey: #function) ?? []
            } catch {
                log.error("decoding beaches value: \(error)")
                return []
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
                notifyObservers(about: #function)
            } catch {
                log.error("encoding beaches newValue: \(error)")
            }
        }
    }

    var checklists: Checklists? {
        get {
            do {
                return try get(objectType: Checklists.self, forKey: #function)
            } catch {
                log.error("decoding checklists value: \(error)")
                return nil
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
                notifyObservers(about: #function)
            } catch {
                log.error("encoding checklists newValue: \(error)")
            }
        }
    }

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
                try set(object: newValue, forKey: #function)
                notifyObservers(about: #function)
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
                try set(object: newRankingsFilter, forKey: #function)
            } catch {
                log.error("encoding rankingsFilter newValue: \(error)")
            }
        }
    }

    var token: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }

    var unCountries: [Country] {
        get {
            do {
                return try get(objectType: [Country].self, forKey: #function) ?? []
            } catch {
                log.error("decoding unCountries value: \(error)")
                return []
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
                notifyObservers(about: #function)
            } catch {
                log.error("encoding unCountries newValue: \(error)")
            }
        }
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
                try set(object: newUser, forKey: #function)
                notifyObservers(about: #function)
            } catch {
                log.error("encoding user newValue: \(error)")
            }
        }
    }

    var whs: [WHS] {
        get {
            do {
                return try get(objectType: [WHS].self, forKey: #function) ?? []
            } catch {
                log.error("decoding WHS value: \(error)")
                return []
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
                notifyObservers(about: #function)
            } catch {
                log.error("encoding WHS newValue: \(error)")
            }
        }
    }
}
