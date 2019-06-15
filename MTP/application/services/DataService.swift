// @copyright Trollwerks Inc.

import JWTDecode
import RealmSwift

// swiftlint:disable file_length

protocol DataService: AnyObject, Observable, ServiceProvider {

    var beaches: [Beach] { get }
    var countries: [Country] { get }
    var divesites: [DiveSite] { get }
    var dismissed: Checked? { get set }
    var email: String { get set }
    var etags: [String: String] { get set }
    var golfcourses: [GolfCourse] { get }
    var lastRankingsQuery: RankingsQuery { get set }
    var locations: [Location] { get }
    var mapDisplay: ChecklistFlags { get set }
    var notified: Checked? { get set }
    var restaurants: [Restaurant] { get }
    var settings: SettingsJSON? { get set }
    var token: String { get set }
    var triggered: Checked? { get set }
    var uncountries: [UNCountry] { get }
    var user: UserJSON? { get set }
    var visited: Checked? { get set }
    var whss: [WHS] { get }
    var worldMap: WorldMap { get }

    func get(country id: Int?) -> Country?
    func get(location id: Int?) -> Location?
    func get(locationPhotos id: Int) -> [Photo]
    func get(locationPosts id: Int) -> [Post]
    func get(locations filter: String) -> [Location]
    func getPhotosPages(user id: Int) -> Results<PhotosPageInfo>
    func get(photo: Int) -> Photo
    func getPosts(user id: Int) -> [Post]
    func get(user id: Int,
             photos location: Int?) -> [Photo]
    func get(rankings query: RankingsQuery) -> Results<RankingsPageInfo>
    func get(scorecard list: Checklist, user id: Int?) -> Scorecard?
    func get(user id: Int) -> User?
    func get(whs id: Int) -> WHS?

    func hasChildren(whs id: Int) -> Bool
    func hasVisitedChildren(whs id: Int) -> Bool

    func set(beaches: [PlaceJSON])
    func set(countries: [CountryJSON])
    func set(divesites: [PlaceJSON])
    func set(golfcourses: [PlaceJSON])
    func set(locations: [LocationJSON])
    func set(location id: Int,
             photos: PhotosInfoJSON)
    func set(location id: Int,
             posts: [PostJSON])
    func set(photos page: Int,
             user id: Int,
             info: PhotosPageInfoJSON)
    func set(posts: [PostJSON])
    func set(restaurants: [RestaurantJSON])
    func set(rankings query: RankingsQuery,
             info: RankingsPageInfoJSON)
    func set(scorecard: ScorecardWrapperJSON)
    func set(uncountries: [LocationJSON])
    func set(user data: UserJSON)
    func set(whss: [WHSJSON])

    func deletePhotos(user id: Int)
}

// MARK: - User state

extension DataService {

    var isLoggedIn: Bool {
        guard !token.isEmpty else { return false }
        guard let jwt = try? decode(jwt: token),
              !jwt.expired else {
            // Appears to have 1 year expiry -- can we refresh?
            logOut()
            return false
        }
        // https://github.com/auth0/JWTDecode.swift/issues/70
        // let expired = jwt.expiresAt < Date().toUTC?
        return true
    }

    var isVisitsLoaded: Bool {
        return visited != nil
    }

    func logOut() {
        FacebookButton.logOut()
        MTP.unthrottle()

        if let id = user?.id {
            deletePhotos(user: id)
        }
        dismissed = nil
        email = ""
        etags = [:]
        lastRankingsQuery = RankingsQuery()
        notified = nil
        set(posts: [])
        token = ""
        triggered = nil
        user = nil
        visited = nil
    }
}

final class DataServiceImpl: DataService {

    private let defaults = UserDefaults.standard
    private let realm = RealmController()

    func deletePhotos(user id: Int) {
        realm.deletePhotos(user: id)
    }

    var beaches: [Beach] {
        return realm.beaches
    }

    func set(beaches: [PlaceJSON]) {
        realm.set(beaches: beaches)
        notify(change: .beaches)
    }

    var countries: [Country] {
        return realm.countries
    }

    func get(country id: Int?) -> Country? {
        return realm.country(id: id)
    }

    func set(countries: [CountryJSON]) {
        realm.set(countries: countries)
    }

    var divesites: [DiveSite] {
        return realm.divesites
    }

    func set(divesites: [PlaceJSON]) {
        realm.set(divesites: divesites)
        notify(change: .divesites)
    }

    var dismissed: Checked? {
        get { return defaults.dismissed }
        set {
            defaults.dismissed = newValue
            notify(change: .dismissed)
        }
    }

    var email: String {
        get { return defaults.email }
        set {
            defaults.email = newValue
        }
    }

    var etags: [String: String] {
        get { return defaults.etags }
        set {
            defaults.etags = newValue
        }
    }

    var golfcourses: [GolfCourse] {
        return realm.golfcourses
    }

    func set(golfcourses: [PlaceJSON]) {
        realm.set(golfcourses: golfcourses)
        notify(change: .golfcourses)
    }

    var lastRankingsQuery: RankingsQuery {
        get { return defaults.lastRankingsQuery ?? RankingsQuery() }
        set {
            defaults.lastRankingsQuery = newValue
        }
    }

    var locations: [Location] {
        return realm.locations
    }

    func get(location id: Int?) -> Location? {
        return realm.location(id: id)
    }

    func get(locationPhotos id: Int) -> [Photo] {
        return realm.photos(location: id)
    }

    func get(locationPosts id: Int) -> [Post] {
        return realm.posts(location: id)
    }

    func get(locations filter: String) -> [Location] {
        return realm.locations(filter: filter)
    }

    func set(locations: [LocationJSON]) {
        realm.set(locations: locations)
        notify(change: .locations)
    }

    var mapDisplay: ChecklistFlags {
        get { return defaults.mapDisplay ?? ChecklistFlags() }
        set {
            defaults.mapDisplay = newValue
        }
    }

    var notified: Checked? {
        get { return defaults.notified }
        set {
            defaults.notified = newValue
            notify(change: .notified)
        }
    }

    func getPhotosPages(user id: Int) -> Results<PhotosPageInfo> {
        return realm.photosPages(user: id)
    }

    func get(photo: Int) -> Photo {
        return realm.photo(id: photo) ?? Photo()
    }

    func get(user id: Int,
             photos location: Int?) -> [Photo] {
        guard let location = location else { return [] }

        return realm.photos(user: id, location: location)
    }

    func set(location id: Int,
             photos: PhotosInfoJSON) {
        realm.set(locationPhotos: id, info: photos)
        notify(change: .locationPhotos, object: id)
    }

    func set(location id: Int,
             posts: [PostJSON]) {
        realm.set(posts: posts)
        notify(change: .locationPosts, object: id)
    }

    func set(photos page: Int,
             user id: Int,
             info: PhotosPageInfoJSON) {
        if info.paging.perPage != PhotosPageInfo.perPage {
            log.warning("expect 25 users per page not \(info.paging.perPage)")
        }

        realm.set(photos: page, user: id, info: info)
        notify(change: .photoPages, object: page)
    }

    func getPosts(user id: Int) -> [Post] {
        return realm.posts(user: id)
    }

    func set(posts: [PostJSON]) {
        realm.set(posts: posts)
        notify(change: .posts)
    }

    func get(rankings query: RankingsQuery) -> Results<RankingsPageInfo> {
        return realm.rankings(query: query)
    }

    func set(rankings query: RankingsQuery,
             info: RankingsPageInfoJSON) {
        if info.users.perPage != RankingsPageInfo.perPage {
            log.warning("expect 50 users per page not \(info.users.perPage)")
        }

        realm.set(rankings: query, info: info)
        notify(change: .rankings, object: query)
    }

    var restaurants: [Restaurant] {
        return realm.restaurants
    }

    func set(restaurants: [RestaurantJSON]) {
        realm.set(restaurants: restaurants)
        notify(change: .restaurants)
    }

    func get(scorecard list: Checklist, user id: Int?) -> Scorecard? {
        guard let id = id else { return nil }
        return realm.scorecard(list: list, id: id)
    }

    func set(scorecard: ScorecardWrapperJSON) {
        realm.set(scorecard: scorecard)
        notify(change: .scorecard)
    }

    var settings: SettingsJSON? {
        get { return defaults.settings }
        set {
            defaults.settings = newValue
            notify(change: .settings)
        }
    }

    var token: String {
        get { return defaults.token }
        set {
            defaults.token = newValue
        }
    }

    var triggered: Checked? {
        get { return defaults.triggered }
        set {
            defaults.triggered = newValue
            notify(change: .triggered)
        }
    }

    var uncountries: [UNCountry] {
        return realm.uncountries
    }

    func set(uncountries: [LocationJSON]) {
        realm.set(uncountries: uncountries)
        notify(change: .uncountries)
    }

    var user: UserJSON? {
        get { return defaults.user }
        set {
            defaults.user = newValue
            notify(change: .user)
            if let newValue = newValue {
                set(user: newValue)
            }
        }
    }

    func get(user id: Int) -> User? {
        return realm.user(id: id)
    }

    var visited: Checked? {
        get { return defaults.visited }
        set {
            defaults.visited = newValue
            if let oldUser = user,
               let visited = newValue {
                user = oldUser.updated(visited: visited)
            }
            notify(change: .visited)
        }
    }

    func get(whs id: Int) -> WHS? {
        return realm.whs(id: id)
    }

    func hasChildren(whs id: Int) -> Bool {
        return !realm.whss.filter { $0.parentId == id }.isEmpty
    }

    func hasVisitedChildren(whs id: Int) -> Bool {
        let children = realm.whss.filter { $0.parentId == id }
        let visits = visited?.whss ?? []
        for child in children {
            if visits.contains(child.id) {
                return true
            }
        }
        return false
    }

    func set(user data: UserJSON) {
        realm.set(user: data)
        notify(change: .userId)
    }

    var whss: [WHS] {
        return realm.whss
    }

    func set(whss: [WHSJSON]) {
        realm.set(whss: whss)
        notify(change: .whss)
    }

    var worldMap = WorldMap()
}

// MARK: - Observable

enum DataServiceChange: String {

    case beaches
    case dismissed
    case divesites
    case golfcourses
    case locationPhotos
    case locationPosts
    case locations
    case notified
    case photoPages
    case posts
    case rankings
    case restaurants
    case scorecard
    case settings
    case triggered
    case uncountries
    case user
    case userId
    case visited
    case whss
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
}

extension DataService {

    var statusKey: StatusKey {
        return DataServiceObserver.statusKey
    }

    var notification: Notification.Name {
        return DataServiceObserver.notification
    }

    func notify(change: DataServiceChange,
                object: Any? = nil) {
        var info: [AnyHashable: Any] = [:]
        if let object = object {
            info[StatusKey.value.rawValue] = object
        }
        notify(observers: change.rawValue, info: info)
    }

    func observer(of: DataServiceChange,
                  handler: @escaping NotificationHandler) -> Observer {
        return DataServiceObserver(of: of, notify: handler)
    }
}

extension Checklist {

    func observer(handler: @escaping NotificationHandler) -> Observer {
        return DataServiceObserver(of: change, notify: handler)
    }

    var change: DataServiceChange {
        switch self {
        case .beaches:
            return .beaches
        case .divesites:
            return .divesites
        case .golfcourses:
            return .golfcourses
        case .locations:
            return .locations
        case .restaurants:
            return .restaurants
        case .uncountries:
            return .uncountries
        case .whss:
            return .whss
        }
    }
}
