// @copyright Trollwerks Inc.

import Foundation

extension UserDefaults: ServiceProvider {

    /// Blocked photos
    var blockedPhotos: [Int] {
        get {
            do {
                return try get(objectType: [Int].self, forKey: #function) ?? []
            } catch {
                log.error("decoding blockedPhotos value: \(error)")
                return []
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding blockedPhotos newValue: \(error)")
            }
        }
    }

    /// Blocked posts
    var blockedPosts: [Int] {
        get {
            do {
                return try get(objectType: [Int].self, forKey: #function) ?? []
            } catch {
                log.error("decoding blockedPosts value: \(error)")
                return []
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding blockedPosts newValue: \(error)")
            }
        }
    }

    /// Blocked users
    var blockedUsers: [Int] {
        get {
            do {
                return try get(objectType: [Int].self, forKey: #function) ?? []
            } catch {
                log.error("decoding blockedUsers value: \(error)")
                return []
            }
        }
        set {
            do {
                try set(object: newValue, forKey: #function)
            } catch {
                log.error("encoding blockedUsers newValue: \(error)")
            }
        }
    }

    /// Dismissed timestamps
    var dismissed: Timestamps? {
        get {
            do {
                return try get(objectType: Timestamps.self, forKey: #function)
            } catch {
                log.error("decoding dismissed value: \(error)")
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
                log.error("encoding dismissed newValue: \(error)")
            }
        }
    }

    /// Email stash during signup
    var email: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }

    /// If-None-Match cache
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

    /// Group hotels by brand?
    var hotelsGroupBrand: Bool {
        get { return bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }

    /// Rankings filter
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

    /// Displayed types
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

    /// Notified timestamps
    var notified: Timestamps? {
        get {
            do {
                return try get(objectType: Timestamps.self, forKey: #function)
            } catch {
                log.error("decoding notified value: \(error)")
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
                log.error("encoding notified newValue: \(error)")
            }
        }
    }

    /// Login token
    var token: String {
        get { return string(forKey: #function) ?? "" }
        set { set(newValue, forKey: #function) }
    }

    /// Triggered timestamps
    var triggered: Timestamps? {
        get {
            do {
                return try get(objectType: Timestamps.self, forKey: #function)
            } catch {
                log.error("decoding triggered value: \(error)")
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
                log.error("encoding triggered newValue: \(error)")
            }
        }
    }

    /// Updated timestamps
    var updated: Timestamps? {
        get {
            do {
                return try get(objectType: Timestamps.self, forKey: #function)
            } catch {
                log.error("decoding updated value: \(error)")
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
                log.error("encoding updated newValue: \(error)")
            }
        }
    }

    /// User info
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

    /// User visits
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
