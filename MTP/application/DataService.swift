// @copyright Trollwerks Inc.

import JWTDecode
import UIKit

protocol DataService: AnyObject, Observable, ServiceProvider {

    var beaches: [Beach] { get }
    var checklists: Checklists? { get set }
    var divesites: [DiveSite] { get }
    var email: String { get set }
    var etags: [String: String] { get set }
    var golfcourses: [GolfCourse] { get }
    var lastRankingsQuery: RankingsQuery? { get set }
    var locations: [Location] { get }
    var name: String { get set }
    var password: String { get set }
    var rankingsPages: [String: RankingsPageInfoJSON] { get set }
    var restaurants: [Restaurant] { get }
    var token: String { get set }
    var uncountries: [UNCountry] { get }
    var user: UserJSON? { get set }
    var whss: [WHS] { get }

    func get(userId: Int) -> User
    func set(beaches: [PlaceJSON])
    func set(divesites: [PlaceJSON])
    func set(golfcourses: [PlaceJSON])
    func set(locations: [LocationJSON])
    func set(restaurants: [RestaurantJSON])
    func set(uncountries: [LocationJSON])
    func set(userId: UserJSON)
    func set(userIds: [RankedUserJSON])
    func set(whss: [WHSJSON])
    func update(page: RankingsPageInfoJSON,
                for query: RankingsQuery)
}

// MARK: - User state

extension DataService {

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

    func logOut() {
        FacebookButton.logOut()
        email = ""
        token = ""
        name = ""
        password = ""
        user = nil
    }
}

final class DataServiceImpl: DataService {

    private let defaults = UserDefaults.standard
    private let realm = RealmController()

    var beaches: [Beach] {
        return realm.beaches
    }

    func set(beaches: [PlaceJSON]) {
        realm.set(beaches: beaches)
        notifyObservers(about: #function)
    }

    var checklists: Checklists? {
        get { return defaults.checklists }
        set {
            defaults.checklists = newValue
            notifyObservers(about: #function)
        }
    }

    var divesites: [DiveSite] {
        return realm.divesites
    }

    func set(divesites: [PlaceJSON]) {
        realm.set(divesites: divesites)
        notifyObservers(about: #function)
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

    var golfcourses: [GolfCourse] {
        return realm.golfcourses
    }

    func set(golfcourses: [PlaceJSON]) {
        realm.set(golfcourses: golfcourses)
        notifyObservers(about: #function)
    }

    var lastRankingsQuery: RankingsQuery? {
        get { return defaults.lastRankingsQuery }
        set {
            defaults.lastRankingsQuery = newValue
            notifyObservers(about: #function)
        }
    }

    var locations: [Location] {
        return realm.locations
    }

    func set(locations: [LocationJSON]) {
        realm.set(locations: locations)
        notifyObservers(about: #function)
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

    var rankingsPages: [String: RankingsPageInfoJSON] {
        get { return defaults.rankingsPages }
        set {
            defaults.rankingsPages = newValue
            notifyObservers(about: #function)
        }
    }

    var restaurants: [Restaurant] {
        return realm.restaurants
    }

    func set(restaurants: [RestaurantJSON]) {
        realm.set(restaurants: restaurants)
        notifyObservers(about: #function)
    }

    var token: String {
        get { return defaults.token }
        set {
            defaults.token = newValue
            notifyObservers(about: #function)
        }
    }

    var uncountries: [UNCountry] {
        return realm.uncountries
    }

    func set(uncountries: [LocationJSON]) {
        realm.set(uncountries: uncountries)
        notifyObservers(about: #function)
    }

    var user: UserJSON? {
        get { return defaults.user }
        set {
            defaults.user = newValue
            notifyObservers(about: #function)
        }
    }

    func get(userId: Int) -> User {
        return realm.user(id: userId) ?? User()
    }

    func set(userId: UserJSON) {
        realm.set(userId: userId)
        notifyObservers(about: #function)
    }

    func set(userIds: [RankedUserJSON]) {
        realm.set(userIds: userIds)
        notifyObservers(about: #function)
    }

    var whss: [WHS] {
        return realm.whss
    }

    func set(whss: [WHSJSON]) {
        realm.set(whss: whss)
        notifyObservers(about: #function)
    }

    func update(page: RankingsPageInfoJSON,
                for query: RankingsQuery) {
        rankingsPages[query.key] = page
        realm.set(userIds: page.users.data)
        notifyObservers(about: #function)
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
