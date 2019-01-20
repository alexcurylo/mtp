// @copyright Trollwerks Inc.

import Foundation

extension UserDefaults: Gestalt {

    var checklistBeaches: [Int] {
        get {
            do {
                return try get(objectType: [Int].self, forKey: #function) ?? []
            } catch {
                log.error("decoding checklistBeaches value: \(error)")
                return []
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding checklistBeaches newValue: \(error)")
            }
        }
    }

    var checklistLocations: [Int] {
        get {
            do {
                return try get(objectType: [Int].self, forKey: #function) ?? []
            } catch {
                log.error("decoding checklistLocations value: \(error)")
                return []
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding checklistLocations newValue: \(error)")
            }
        }
    }

    var checklistUNCountries: [Int] {
        get {
            do {
                return try get(objectType: [Int].self, forKey: #function) ?? []
            } catch {
                log.error("decoding checklistUNCountries value: \(error)")
                return []
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding checklistUNCountries newValue: \(error)")
            }
        }
    }

    var checklistWHSs: [Int] {
        get {
            do {
                return try get(objectType: [Int].self, forKey: #function) ?? []
            } catch {
                log.error("decoding checklistWHSs value: \(error)")
                return []
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding checklistWHSs newValue: \(error)")
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
