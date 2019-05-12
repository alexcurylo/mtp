// @copyright Trollwerks Inc.

import Foundation

extension UserDefaults: ServiceProvider {

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
            guard let newValue = newValue else {
                set(nil, forKey: #function)
                return
            }
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding lastRankingsQuery newValue: \(error)")
            }
        }
    }

    var mapDisplay: ChecklistFlags? {
        get {
            do {
                return try get(objectType: ChecklistFlags.self, forKey: #function)
            } catch {
                log.error("decoding mapDisplay value: \(error)")
                return nil
            }
        }
        set {
            guard let newValue = newValue else {
                set(nil, forKey: #function)
                return
            }
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding mapDisplay newValue: \(error)")
            }
        }
    }

    var token: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }

    var triggered: Checked? {
        get {
            do {
                return try get(objectType: Checked.self, forKey: #function)
            } catch {
                log.error("decoding visited value: \(error)")
                return nil
            }
        }
        set {
            guard let newValue = newValue else {
                set(nil, forKey: #function)
                return
            }
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding visited newValue: \(error)")
            }
        }
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
            guard let newValue = newValue else {
                set(nil, forKey: #function)
                return
            }
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding user newValue: \(error)")
            }
        }
    }

    var visited: Checked? {
        get {
            do {
                return try get(objectType: Checked.self, forKey: #function)
            } catch {
                log.error("decoding visited value: \(error)")
                return nil
            }
        }
        set {
            guard let newValue = newValue else {
                set(nil, forKey: #function)
                return
            }
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding visited newValue: \(error)")
            }
        }
    }
}
