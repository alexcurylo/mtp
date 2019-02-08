// @copyright Trollwerks Inc.

import JWTDecode
import UIKit

protocol DataService: AnyObject, Observable, ServiceProvider {

    var beaches: [Beach] { get }
    var checklists: Checklists? { get set }
    var countries: [Country] { get }
    var divesites: [DiveSite] { get }
    var email: String { get set }
    var etags: [String: String] { get set }
    var golfcourses: [GolfCourse] { get }
    var lastRankingsQuery: RankingsQuery { get set }
    var locations: [Location] { get }
    var name: String { get set }
    var password: String { get set }
    var restaurants: [Restaurant] { get }
    var token: String { get set }
    var uncountries: [UNCountry] { get }
    var user: UserJSON? { get set }
    var whss: [WHS] { get }

    func get(country id: Int?) -> Country?
    func get(location id: Int?) -> Location?
    func get(locations filter: String) -> [Location]
    func get(rankings query: RankingsQuery) -> RankingsPageInfo?
    func get(user id: Int) -> User

    func set(beaches: [PlaceJSON])
    func set(countries: [CountryJSON])
    func set(divesites: [PlaceJSON])
    func set(golfcourses: [PlaceJSON])
    func set(locations: [LocationJSON])
    func set(restaurants: [RestaurantJSON])
    func set(rankings query: RankingsQuery,
             info: RankingsPageInfoJSON)
    func set(uncountries: [LocationJSON])
    func set(userId: UserJSON)
    func set(whss: [WHSJSON])
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

    var countries: [Country] {
        return realm.countries
    }

    func get(country id: Int?) -> Country? {
        return realm.country(id: id)
    }

    func set(countries: [CountryJSON]) {
        realm.set(countries: countries)
        notifyObservers(about: #function)
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

    var lastRankingsQuery: RankingsQuery {
        get { return defaults.lastRankingsQuery ?? RankingsQuery() }
        set {
            defaults.lastRankingsQuery = newValue
            notifyObservers(about: #function)
        }
    }

    var locations: [Location] {
        return realm.locations
    }

    func get(location id: Int?) -> Location? {
        return realm.location(id: id)
    }

    func get(locations filter: String) -> [Location] {
        return realm.locations(filter: filter)
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

    func get(rankings query: RankingsQuery) -> RankingsPageInfo? {
        return realm.rankings(query: query)
    }

    func set(rankings query: RankingsQuery,
             info: RankingsPageInfoJSON) {
        if info.users.perPage != 50 {
            log.warning("expect 50 users per page not \(info.users.perPage)")
        }

        realm.set(rankings: query, info: info)
        notifyObservers(about: #function)
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

    func get(user id: Int) -> User {
        return realm.user(id: id) ?? User()
    }

    func set(userId: UserJSON) {
        realm.set(userId: userId)
        notifyObservers(about: #function)
    }

    var whss: [WHS] {
        return realm.whss
    }

    func set(whss: [WHSJSON]) {
        realm.set(whss: whss)
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
