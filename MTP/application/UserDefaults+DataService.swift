// @copyright Trollwerks Inc.

import Foundation

extension UserDefaults: ServiceProvider {

    var beaches: [Place] {
        get {
            do {
                return try get(objectType: [Place].self, forKey: #function) ?? []
            } catch {
                log.error("decoding beaches value: \(error)")
                return []
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
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
            } catch {
                log.error("encoding checklists newValue: \(error)")
            }
        }
    }

    var divesites: [Place] {
        get {
            do {
                return try get(objectType: [Place].self, forKey: #function) ?? []
            } catch {
                log.error("decoding divesites value: \(error)")
                return []
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding divesites newValue: \(error)")
            }
        }
    }

    var email: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }

    var etags: [String: String] {
        get {
            do {
                return try get(objectType: [String: String].self, forKey: #function) ?? [:]
            } catch {
                log.error("decoding etags value: \(error)")
                return [:]
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding etags newValue: \(error)")
            }
        }
    }

    var golfcourses: [Place] {
        get {
            do {
                return try get(objectType: [Place].self, forKey: #function) ?? []
            } catch {
                log.error("decoding golfcourses value: \(error)")
                return []
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding golfcourses newValue: \(error)")
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

    var rankingsPages: [String: RankingsPage] {
        get {
            do {
                return try get(objectType: [String: RankingsPage].self, forKey: #function) ?? [:]
            } catch {
                log.error("decoding rankingsPages value: \(error)")
                return [:]
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding rankingsPages newValue: \(error)")
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
            } catch {
                log.error("encoding user newValue: \(error)")
            }
        }
    }

    var whss: [WHS] {
        get {
            do {
                return try get(objectType: [WHS].self, forKey: #function) ?? []
            } catch {
                log.error("decoding whss value: \(error)")
                return []
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding whss newValue: \(error)")
            }
        }
    }
}
