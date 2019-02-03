// @copyright Trollwerks Inc.

import Foundation

extension UserDefaults: ServiceProvider {

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

    var lastRankingsQuery: RankingsQuery? {
        get {
            do {
                return try get(objectType: RankingsQuery.self, forKey: #function)
            } catch {
                log.error("decoding lastRankingsQuery value: \(error)")
                return nil
            }
        }
        set {
            guard let newQuery = newValue else {
                set(nil, forKey: #function)
                return
            }
            do {
                try set(object: newQuery, forKey: #function)
            } catch {
                log.error("encoding lastRankingsQuery newValue: \(error)")
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

    var rankingsPages: [String: RankingsPageInfoJSON] {
        get {
            do {
                return try get(objectType: [String: RankingsPageInfoJSON].self, forKey: #function) ?? [:]
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

    var user: UserJSON? {
        get {
            do {
                return try get(objectType: UserJSON.self, forKey: #function)
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
}
