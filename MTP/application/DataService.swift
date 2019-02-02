// @copyright Trollwerks Inc.

import JWTDecode
import UIKit

protocol DataService: AnyObject, Observable, ServiceProvider {

    var beaches: [Place] { get set }
    var checklists: Checklists? { get set }
    var divesites: [Place] { get set }
    var email: String { get set }
    var etags: [String: String] { get set }
    var golfcourses: [Place] { get set }
    var locations: [Location] { get set }
    var name: String { get set }
    var password: String { get set }
    var rankingsFilter: UserFilter? { get set }
    var rankingsPages: [String: RankingsPage] { get set }
    var restaurants: [Restaurant] { get set }
    var token: String { get set }
    var uncountries: [Location] { get set }
    var user: User? { get set }
    var whss: [WHS] { get set }
}

// MARK: - User state

extension DataService {

    func logOut() {
        FacebookButton.logOut()
        email = ""
        token = ""
        name = ""
        password = ""
        user = nil
    }

    var isLoggedIn: Bool {
        guard !token.isEmpty,
              let jwt = try? decode(jwt: token),
              let expiry = jwt.expiresAt else { return false }
        // https://github.com/auth0/JWTDecode.swift/issues/70
        let expired = expiry > Date().toUTC
        if expired {
            log.debug("token expired -- should we be refreshing somehow?")
        }
        return expired
    }
}

final class DataServiceImpl: DataService {

    let defaults = UserDefaults.standard

    var beaches: [Place] {
        get { return defaults.beaches }
        set {
            defaults.beaches = newValue
            notifyObservers(about: #function)
        }
    }

    var checklists: Checklists? {
        get { return defaults.checklists }
        set {
            defaults.checklists = newValue
            notifyObservers(about: #function)
        }
    }

    var divesites: [Place] {
        get { return defaults.divesites }
        set {
            defaults.divesites = newValue
            notifyObservers(about: #function)
        }
    }

    var email: String {
        get { return defaults.email }
        set {
            defaults.email = newValue
            notifyObservers(about: #function)
        }
    }

    var etags: [String: String] {
        get { return defaults.etags }
        set {
            defaults.etags = newValue
            notifyObservers(about: #function)
        }
    }

    var golfcourses: [Place] {
        get { return defaults.golfcourses }
        set {
            defaults.golfcourses = newValue
            notifyObservers(about: #function)
        }
    }

    var locations: [Location] {
        get { return defaults.locations }
        set {
            defaults.locations = newValue
            notifyObservers(about: #function)
        }
    }

    var name: String {
        get { return defaults.name }
        set {
            defaults.name = newValue
            notifyObservers(about: #function)
        }
    }

    var password: String {
        get { return defaults.password }
        set {
            defaults.password = newValue
            notifyObservers(about: #function)
        }
    }

    var rankingsFilter: UserFilter? {
        get { return defaults.rankingsFilter }
        set {
            defaults.rankingsFilter = newValue
            notifyObservers(about: #function)
        }
    }

    var rankingsPages: [String: RankingsPage] {
        get { return defaults.rankingsPages }
        set {
            defaults.rankingsPages = newValue
            notifyObservers(about: #function)
        }
    }

    var restaurants: [Restaurant] {
        get { return defaults.restaurants }
        set {
            defaults.restaurants = newValue
            notifyObservers(about: #function)
        }
    }

    var token: String {
        get { return defaults.token }
        set {
            defaults.token = newValue
            notifyObservers(about: #function)
        }
    }

    var uncountries: [Location] {
        get { return defaults.uncountries }
        set {
            defaults.uncountries = newValue
            notifyObservers(about: #function)
        }
    }

    var user: User? {
        get { return defaults.user }
        set {
            defaults.user = newValue
            notifyObservers(about: #function)
        }
    }

    var whss: [WHS] {
        get { return defaults.whss }
        set {
            defaults.whss = newValue
            notifyObservers(about: #function)
        }
    }
}

// MARK: - Observable

enum DataServiceChange: String {

    case checklists
    case user
    // and the contents of Checklist
}

final class DataServiceObserver: ObserverImpl {

    static let notification = Notification.Name("DataServiceChange")
    static let statusKey = StatusKey.change

    init(of value: DataServiceChange,
         notify: @escaping NotificationHandler) {
        super.init(notification: DataServiceObserver.notification,
                   key: DataServiceObserver.statusKey,
                   value: value.rawValue,
                   notify: notify)
    }

    init(of value: Checklist,
         notify: @escaping NotificationHandler) {
        super.init(notification: DataServiceObserver.notification,
                   key: DataServiceObserver.statusKey,
                   value: value.rawValue,
                   notify: notify)
    }
}

extension DataService {

    var statusKey: StatusKey {
        return DataServiceObserver.statusKey
    }

    var notification: Notification.Name {
        return DataServiceObserver.notification
    }

    func userObserver(handler: @escaping NotificationHandler) -> Observer {
        return DataServiceObserver(of: .user, notify: handler)
    }

    func checklistsObserver(handler: @escaping NotificationHandler) -> Observer {
        return DataServiceObserver(of: .checklists, notify: handler)
    }
}

extension Checklist {

    func observer(handler: @escaping NotificationHandler) -> Observer {
        return DataServiceObserver(of: self, notify: handler)
    }
}
