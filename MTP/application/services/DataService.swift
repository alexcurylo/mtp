// @copyright Trollwerks Inc.

import JWTDecode
import RealmSwift

// swiftlint:disable file_length

/// Provides stored data functionality
protocol DataService: AnyObject, Observable, ServiceProvider {

    /// Callback handler type
    typealias Completion = (Bool) -> Void

    /// Beaches
    var beaches: [Beach] { get }
    /// Blocked photos
    var blockedPhotos: [Int] { get set }
    /// Blocked posts
    var blockedPosts: [Int] { get set }
    /// Blocked users
    var blockedUsers: [Int] { get set }
    /// Countries
    var countries: [Country] { get }
    /// Dive sites
    var divesites: [DiveSite] { get }
    /// Dismissed timestamps
    var dismissed: Timestamps? { get set }
    /// Email stash during signup
    var email: String { get set }
    /// If-None-Match cache
    var etags: [String: String] { get set }
    /// Golf courses
    var golfcourses: [GolfCourse] { get }
    /// Rankings filter
    var lastRankingsQuery: RankingsQuery { get set }
    /// Locations
    var locations: [Location] { get }
    /// Displayed types
    var mapDisplay: ChecklistFlags { get set }
    /// Mappables
    var mappables: [Mappable] { get }
    /// Notified timestamps
    var notified: Timestamps? { get set }
    /// Restaurants
    var restaurants: [Restaurant] { get }
    /// Login token
    var token: String { get set }
    /// Triggered timestamps
    var triggered: Timestamps? { get set }
    /// UN Countries
    var uncountries: [UNCountry] { get }
    /// Updated timestamps
    var updated: Timestamps? { get set }
    /// User info
    var user: UserJSON? { get set }
    /// User visits
    var visited: Checked? { get set }
    /// WHSs
    var whss: [WHS] { get }
    /// World map
    var worldMap: WorldMap { get }

    /// Block a photo
    ///
    /// - Parameter id: Photo ID
    func block(photo id: Int)
    /// Block a post
    ///
    /// - Parameter id: Post ID
    func block(post id: Int)
    /// Block a user
    ///
    /// - Parameter id: User ID
    func block(user id: Int) -> Bool

    /// Get country
    ///
    /// - Parameter id: country ID
    /// - Returns: Country if found
    func get(country id: Int?) -> Country?
    /// Get location
    ///
    /// - Parameter id: location ID
    /// - Returns: Location if found
    func get(location id: Int?) -> Location?
    /// Get location photos
    ///
    /// - Parameter id: location ID
    /// - Returns: Photos if found
    func get(locationPhotos id: Int) -> [Photo]
    /// Get location posts
    ///
    /// - Parameter id: location ID
    /// - Returns: Posts if found
    func get(locationPosts id: Int) -> [Post]
    /// Get filtered locations
    ///
    /// - Parameter filter: Filter
    /// - Returns: Locations if found
    func get(locations filter: String) -> [Location]
    /// Get place
    ///
    /// - Parameter item: list and ID
    /// - Returns: Place if found
    func get(mappable item: Checklist.Item) -> Mappable?
    /// Get places
    ///
    /// - Parameter list: Checklist
    /// - Returns: Places in list
    func get(mappables list: Checklist) -> [Mappable]
    /// Get matching places
    ///
    /// - Parameter matching: String
    /// - Returns: Places matching
    func get(mappables matching: String) -> [Mappable]
    /// Get milestones
    ///
    /// - Parameter list: Checklist
    /// - Returns: Milestones if found
    func get(milestones list: Checklist) -> Milestones?
    /// Get user photo pages
    ///
    /// - Parameter id: User ID
    /// - Returns: Photo pages if found
    func getPhotosPages(user id: Int) -> Results<PhotosPageInfo>
    /// Get photo
    ///
    /// - Parameter photo: ID
    /// - Returns: Photo
    func get(photo: Int) -> Photo
    /// Get user posts
    ///
    /// - Parameter id: User ID
    /// - Returns: Posts if found
    func getPosts(user id: Int) -> [Post]
    /// Get user photos by location
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - location: Location
    /// - Returns: Photos if found
    func get(user id: Int,
             photos location: Int?) -> [Photo]
    /// Get rankings pages
    ///
    /// - Parameter query: Filter query
    /// - Returns: Rankings pages if found
    func get(rankings query: RankingsQuery) -> Results<RankingsPageInfo>
    /// Get user scorecard
    ///
    /// - Parameters:
    ///   - list: Checklist
    ///   - id: userID
    /// - Returns: Scorecard if found
    func get(scorecard list: Checklist,
             user id: Int?) -> Scorecard?
    /// Get user
    ///
    /// - Parameter id: User ID
    /// - Returns: User if found
    func get(user id: Int) -> User?
    /// Get WHS
    ///
    /// - Parameter id: WHS ID
    /// - Returns: WHS if found
    func get(whs id: Int) -> WHS?

    /// Does WHS have children?
    ///
    /// - Parameter id: WHS ID
    /// - Returns: Parentage
    func hasChildren(whs id: Int) -> Bool
    /// Visited children list
    ///
    /// - Parameter id: WHS ID
    /// - Returns: Visited children
    func visitedChildren(whs id: Int) -> [WHS]

    /// Set beaches
    ///
    /// - Parameter beaches: API results
    func set(beaches: [PlaceJSON])
    /// Set countries
    ///
    /// - Parameter countries: API results
    func set(countries: [CountryJSON])
    /// Set dive sites
    ///
    /// - Parameter divesites: API results
    func set(divesites: [PlaceJSON])
    /// Set golf courses
    ///
    /// - Parameter golfcourses: API results
    func set(golfcourses: [PlaceJSON])
    /// Set places visited state
    ///
    /// - Parameters:
    ///   - items: Places
    ///   - visited: Visited state
    func set(items: [Checklist.Item],
             visited: Bool)
    /// Set locations
    ///
    /// - Parameter locations: API results
    func set(locations: [LocationJSON])
    /// Set location photos
    ///
    /// - Parameters:
    ///   - id: Location ID
    ///   - photos: API results
    func set(location id: Int,
             photos: PhotosInfoJSON)
    /// Set location posts
    ///
    /// - Parameters:
    ///   - id: Location ID
    ///   - photos: API results
    func set(location id: Int,
             posts: [PostJSON])
    /// Set milestones
    ///
    /// - Parameter milestones: API results
    func set(milestones: SettingsJSON)
    /// Set photo
    ///
    /// - Parameter photo: API result
    func set(photo: PhotoReply)
    /// Set photos page
    ///
    /// - Parameters:
    ///   - page: Index
    ///   - id: User ID
    ///   - info: API results
    func set(photos page: Int,
             user id: Int,
             info: PhotosPageInfoJSON)
    /// Set post
    ///
    /// - Parameter post: API results
    func set(post: PostReply)
    /// Set user posts
    ///
    /// - Parameters:
    ///   - id: Location ID
    ///   - posts: API results
    func set(posts: [PostJSON])
    /// Set restaurants
    ///
    /// - Parameter restaurants: API results
    func set(restaurants: [RestaurantJSON])
    /// Set rankings query
    ///
    /// - Parameters:
    ///   - query: Query
    ///   - info: API results
    func set(rankings query: RankingsQuery,
             info: RankingsPageInfoJSON)
    /// Set scorecard
    ///
    /// - Parameter scorecard: API results
    func set(scorecard: ScorecardWrapperJSON)
    /// Set UN countries
    ///
    /// - Parameter uncountries: API results
    func set(uncountries: [LocationJSON])
    /// Set user
    ///
    /// - Parameter data: API results
    func set(user data: UserJSON)
    /// Set WHSs
    ///
    /// - Parameter whss: API results
    func set(whss: [WHSJSON])

    /// Delete all user photos
    ///
    /// - Parameter id: User ID
    func deletePhotos(user id: Int)

    /// Resolve Realm crossthread reference
    ///
    /// - Parameter reference: Reference
    /// - Returns: Mappable if found
    func resolve(reference: Mappable.Reference) -> Mappable?

    /// Update rankings
    ///
    /// - Parameters:
    ///   - rankings: Checklist
    ///   - then: Completion
    func update(rankings: Checklist,
                then: @escaping Completion)
    /// Update scorecard
    ///
    /// - Parameters:
    ///   - rankings: Checklist
    ///   - then: Completion
    func update(scorecard: Checklist,
                then: @escaping Completion)
    /// Update page stamp
    ///
    /// - Parameter stamp: Page
    func update(stamp: RankingsPageInfo?)
}

// MARK: - Generic DataService

extension DataService {

    /// Is there a logged in user?
    var isLoggedIn: Bool {
        if let loggedIn = ProcessInfo.setting(bool: .loggedIn) {
            return loggedIn
        } else if UIApplication.isUnitTesting {
            return false
        }

        guard !token.isEmpty else { return false }
        guard let jwt = try? decode(jwt: token),
              !jwt.expired else {
            // Appears to have 1 year expiry -- can we refresh?
            logOut()
            return false
        }
        return true
    }

    /// Are visits loaded?
    var isVisitsLoaded: Bool {
        return visited != nil
    }

    /// Log out current user
    func logOut() {
        FacebookButton.logOut()
        report.user(signIn: nil, signUp: nil)

        MTP.unthrottle()
        net.unthrottle()

        if let id = user?.id {
            deletePhotos(user: id)
        }
        blockedPhotos = []
        blockedPosts = []
        blockedUsers = []
        dismissed = nil
        email = ""
        etags = [:]
        lastRankingsQuery = RankingsQuery()
        notified = nil
        set(posts: [])
        token = ""
        triggered = nil
        updated = nil
        user = nil
        visited = nil
    }
}

/// Production implementation of DataService
class DataServiceImpl: DataService {
    // swiftlint:disable:previous type_body_length

    private let defaults = UserDefaults.standard
    private let realm = RealmDataController()

    /// Beaches
    var beaches: [Beach] {
        return realm.beaches
    }

    /// Set beaaches
    ///
    /// - Parameter beaches: API results
    func set(beaches: [PlaceJSON]) {
        realm.set(beaches: beaches)
        notify(change: .beaches)
    }

    /// Blocked photos
    var blockedPhotos: [Int] {
        get { return defaults.blockedPhotos }
        set {
            defaults.blockedPhotos = newValue
            notify(change: .blockedPhotos)
            notify(change: .locationPhotos)
            notify(change: .photoPages)
        }
    }

    /// Blocked posts
    var blockedPosts: [Int] {
        get { return defaults.blockedPosts }
        set {
            defaults.blockedPosts = newValue
            notify(change: .blockedPosts)
            notify(change: .locationPosts)
            notify(change: .posts)
        }
    }

    /// Blocked users
    var blockedUsers: [Int] {
        get { return defaults.blockedUsers }
        set {
            defaults.blockedUsers = newValue
            notify(change: .blockedUsers)
            notify(change: .locationPhotos)
            notify(change: .photoPages)
            notify(change: .locationPosts)
            notify(change: .posts)
        }
    }

    /// Block a photo
    ///
    /// - Parameter id: Photo ID
    func block(photo id: Int) {
        if !blockedPhotos.contains(id) {
            blockedPhotos.append(id)
        }
    }

    /// Block a post
    ///
    /// - Parameter id: Post ID
    func block(post id: Int) {
        if !blockedPosts.contains(id) {
            blockedPosts.append(id)
        }
    }

    /// Block a user
    ///
    /// - Parameter id: User ID
    func block(user id: Int) -> Bool {
        guard id > 0, id != user?.id else {
            note.message(error: L.blockSelf())
            return false
        }
        if !blockedUsers.contains(id) {
            blockedUsers.append(id)
        }
        return true
    }

    /// Countries
    var countries: [Country] {
        return realm.countries
    }

    /// Get country
    ///
    /// - Parameter id: country ID
    /// - Returns: Country if found
    func get(country id: Int?) -> Country? {
        return realm.country(id: id)
    }

    /// Set countries
    ///
    /// - Parameter countries: API results
    func set(countries: [CountryJSON]) {
        realm.set(countries: countries)
    }

    /// Dive sites
    var divesites: [DiveSite] {
        return realm.divesites
    }

    /// Set dive sites
    ///
    /// - Parameter divesites: API results
    func set(divesites: [PlaceJSON]) {
        realm.set(divesites: divesites)
        notify(change: .divesites)
    }

    /// Dismissed timestamps
    var dismissed: Timestamps? {
        get { return defaults.dismissed }
        set {
            defaults.dismissed = newValue
            notify(change: .dismissed)
        }
    }

    /// Email stash during signup
    var email: String {
        get { return defaults.email }
        set {
            defaults.email = newValue
            //saveRealm()
        }
    }

    /// If-None-Match cache
    var etags: [String: String] {
        get { return defaults.etags }
        set {
            defaults.etags = newValue
        }
    }

    /// Golf courses
    var golfcourses: [GolfCourse] {
        return realm.golfcourses
    }

    /// Set golf courses
    ///
    /// - Parameter golfcourses: API results
    func set(golfcourses: [PlaceJSON]) {
        realm.set(golfcourses: golfcourses)
        notify(change: .golfcourses)
    }

    /// Rankings filter
    var lastRankingsQuery: RankingsQuery {
        get { return defaults.lastRankingsQuery ?? RankingsQuery() }
        set {
            defaults.lastRankingsQuery = newValue
        }
    }

    /// Locations
    var locations: [Location] {
        return realm.locations
    }

    /// Get location
    ///
    /// - Parameter id: location ID
    /// - Returns: Location if found
    func get(location id: Int?) -> Location? {
        return realm.location(id: id)
    }

    /// Get location photos
    ///
    /// - Parameter id: location ID
    /// - Returns: Photos if found
    func get(locationPhotos id: Int) -> [Photo] {
        return realm.photos(location: id)
    }

    /// Get location posts
    ///
    /// - Parameter id: location ID
    /// - Returns: Posts if found
    func get(locationPosts id: Int) -> [Post] {
        return realm.posts(location: id)
    }

    /// Get filtered locations
    ///
    /// - Parameter filter: Filter
    /// - Returns: Locations if found
    func get(locations filter: String) -> [Location] {
        return realm.locations(filter: filter)
    }

    /// Get place
    ///
    /// - Parameter item: list and ID
    /// - Returns: Place if found
    func get(mappable item: Checklist.Item) -> Mappable? {
        return realm.mappable(item: item)
    }

    /// Mappables
    var mappables: [Mappable] {
        return realm.mappables(list: nil)
    }

    /// Get places
    ///
    /// - Parameter list: list
    /// - Returns: Places in list
    func get(mappables list: Checklist) -> [Mappable] {
        return realm.mappables(list: list)
    }

    /// Get matching places
    ///
    /// - Parameter matching: String
    /// - Returns: Places matching
    func get(mappables matching: String) -> [Mappable] {
        return realm.mappables(matching: matching)
    }

    /// Set places visited state
    ///
    /// - Parameters:
    ///   - items: Places
    ///   - visited: Visited state
    func set(items: [Checklist.Item],
             visited: Bool) {
        let allItems = withCountry(items: items,
                                   visited: visited)
        var dismissals = dismissed ?? Timestamps()
        var notifications = notified ?? Timestamps()
        var triggers = triggered ?? Timestamps()
        var updates = updated ?? Timestamps()
        var visits = self.visited ?? Checked()
        allItems.forEach { item in
            dismissals.set(item: item, stamped: visited)
            notifications.set(item: item, stamped: visited)
            triggers.set(item: item, stamped: visited)
            updates.set(list: item.list, stamped: true)
            visits.set(item: item, visited: visited)
        }
        dismissed = dismissals
        notified = notifications
        triggered = triggers
        updated = updates
        self.visited = visits
    }

    /// Set locations
    ///
    /// - Parameter locations: API results
    func set(locations: [LocationJSON]) {
        realm.set(locations: locations)
        notify(change: .locations)
    }

    /// Displayed types
    var mapDisplay: ChecklistFlags {
        get { return defaults.mapDisplay ?? ChecklistFlags() }
        set {
            defaults.mapDisplay = newValue
        }
    }

    /// Notified timestamps
    var notified: Timestamps? {
        get { return defaults.notified }
        set {
            defaults.notified = newValue
            notify(change: .notified)
        }
    }

    /// Get user photo pages
    ///
    /// - Parameter id: User ID
    /// - Returns: Photo pages if found
    func getPhotosPages(user id: Int) -> Results<PhotosPageInfo> {
        return realm.photosPages(user: id)
    }

    /// Get photo
    ///
    /// - Parameter photo: ID
    /// - Returns: Photo
    func get(photo: Int) -> Photo {
        return realm.photo(id: photo) ?? Photo()
    }

    /// Get user photos by location
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - location: Location
    /// - Returns: Photos if found
    func get(user id: Int,
             photos location: Int?) -> [Photo] {
        guard let location = location else { return [] }

        return realm.photos(user: id, location: location)
    }

    /// Set location photos
    ///
    /// - Parameters:
    ///   - id: Location ID
    ///   - photos: API results
    func set(location id: Int,
             photos: PhotosInfoJSON) {
        realm.set(locationPhotos: id, info: photos)
        notify(change: .locationPhotos, object: id)
    }

    /// Set location posts
    ///
    /// - Parameters:
    ///   - id: Location ID
    ///   - posts: API results
    func set(location id: Int,
             posts: [PostJSON]) {
        realm.set(posts: posts)
        notify(change: .locationPosts, object: id)
    }

    /// Get milestones
    ///
    /// - Parameter list: Checklist
    /// - Returns: Milestones if found
    func get(milestones list: Checklist) -> Milestones? {
        return realm.milestones(list: list)
    }

    /// Set milestones
    ///
    /// - Parameter milestones: API results
    func set(milestones: SettingsJSON) {
        realm.set(milestones: milestones)
        notify(change: .milestones, object: milestones)
    }

    /// Set photo
    ///
    /// - Parameter photo: API result
    func set(photo: PhotoReply) {
        realm.set(photo: photo)
        notify(change: .photoPages)
    }

    /// Set photos page
    ///
    /// - Parameters:
    ///   - page: Index
    ///   - id: User ID
    ///   - info: API results
    func set(photos page: Int,
             user id: Int,
             info: PhotosPageInfoJSON) {
        if info.paging.perPage != PhotosPageInfo.perPage {
            log.warning("expect 25 users per page not \(info.paging.perPage)")
        }

        realm.set(photos: page, user: id, info: info)
        notify(change: .photoPages, object: page)
    }

    /// Get user posts
    ///
    /// - Parameter id: User ID
    /// - Returns: Posts if found
    func getPosts(user id: Int) -> [Post] {
        return realm.posts(user: id)
    }

    /// Set post
    ///
    /// - Parameter post: API results
    func set(post: PostReply) {
        realm.set(post: post)
        notify(change: .posts)
    }

    /// Set user posts
    ///
    /// - Parameters:
    ///   - id: Location ID
    ///   - posts: API results
    func set(posts: [PostJSON]) {
        realm.set(posts: posts)
        notify(change: .posts)
    }

    /// Get rankings pages
    ///
    /// - Parameter query: Filter query
    /// - Returns: Rankings pages if found
    func get(rankings query: RankingsQuery) -> Results<RankingsPageInfo> {
        return realm.rankings(query: query)
    }

    /// Set rankings query
    ///
    /// - Parameters:
    ///   - query: Query
    ///   - info: API results
    func set(rankings query: RankingsQuery,
             info: RankingsPageInfoJSON) {
        if info.users.perPage != RankingsPageInfo.perPage {
            log.warning("expect 50 users per page not \(info.users.perPage)")
        }

        realm.set(rankings: query, info: info)
        if let list = Checklist(key: query.checklistKey),
           var update = updated,
           update.clear(rankings: list) {
            updated = update
        }
        notify(change: .rankings, object: query)
    }

    /// Restaurants
    var restaurants: [Restaurant] {
        return realm.restaurants
    }

    /// Set restaurants
    ///
    /// - Parameter restaurants: API results
    func set(restaurants: [RestaurantJSON]) {
        realm.set(restaurants: restaurants)
        notify(change: .restaurants)
    }

    /// Get user scorecard
    ///
    /// - Parameters:
    ///   - list: Checklist
    ///   - id: userID
    /// - Returns: Scorecard if found
    func get(scorecard list: Checklist,
             user id: Int?) -> Scorecard? {
        guard let id = id else { return nil }
        return realm.scorecard(list: list, id: id)
    }

    /// Set scorecard
    ///
    /// - Parameter scorecard: API results
    func set(scorecard: ScorecardWrapperJSON) {
        realm.set(scorecard: scorecard)
        if user?.id == Int(scorecard.data.userId),
           let list = Checklist(key: scorecard.data.type) {
            clear(updates: list)
        }
        notify(change: .scorecard)
    }

    /// Login token
    var token: String {
        get { return defaults.token }
        set {
            defaults.token = newValue
        }
    }

    /// Triggered timestamps
    var triggered: Timestamps? {
        get { return defaults.triggered }
        set {
            defaults.triggered = newValue
            notify(change: .triggered)
        }
    }

    /// UN Countries
    var uncountries: [UNCountry] {
        return realm.uncountries
    }

    /// Set UN countries
    ///
    /// - Parameter uncountries: API results
    func set(uncountries: [LocationJSON]) {
        realm.set(uncountries: uncountries)
        notify(change: .uncountries)
    }

    /// Updated timestamps
    var updated: Timestamps? {
        get { return defaults.updated }
        set {
            defaults.updated = newValue
            notify(change: .updated)
        }
    }

    /// User info
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

    /// Get user
    ///
    /// - Parameter id: User ID
    /// - Returns: User if found
    func get(user id: Int) -> User? {
        return realm.user(id: id)
    }

    /// User visits
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

    /// Get WHS
    ///
    /// - Parameter id: WHS ID
    /// - Returns: WHS if found
    func get(whs id: Int) -> WHS? {
        return realm.whs(id: id)
    }

    /// Does WHS have children?
    ///
    /// - Parameter id: WHS ID
    /// - Returns: Parentage
    func hasChildren(whs id: Int) -> Bool {
        return !children(whs: id).isEmpty
    }

    /// Visited children list
    ///
    /// - Parameter id: WHS ID
    /// - Returns: Visited children
    func visitedChildren(whs id: Int) -> [WHS] {
        let visits = visited?.whss ?? []
        return children(whs: id).compactMap {
            visits.contains($0.placeId) ? $0 : nil
        }
    }

    func set(user data: UserJSON) {
        realm.set(user: data)
        notify(change: .userId)
    }

    /// WHSs
    var whss: [WHS] {
        return realm.whss
    }

    /// Set WHSs
    ///
    /// - Parameter whss: API results
    func set(whss: [WHSJSON]) {
        realm.set(whss: whss)
        notify(change: .whss)
    }

    /// World map
    let worldMap = WorldMap()

    /// Delete all user photos
    ///
    /// - Parameter id: User ID
    func deletePhotos(user id: Int) {
        realm.deletePhotos(user: id)
    }

    /// Resolve Realm crossthread reference
    ///
    /// - Parameter reference: Reference
    /// - Returns: Mappable if found
    func resolve(reference: Mappable.Reference) -> Mappable? {
        return realm.resolve(reference: reference)
    }

    /// Update rankings
    ///
    /// - Parameters:
    ///   - rankings: Checklist
    ///   - then: Completion
    func update(rankings: Checklist,
                then: @escaping Completion) {
        guard let status = updated?.updateStatus(rankings: rankings),
              status.isPending else {
                return then(true)
        }

        let query = lastRankingsQuery.with(list: rankings)
        net.loadRankings(query: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success,
                     .failure(NetworkError.notModified):
                    then(true)
                default:
                    then(false)
                }
            }
        }
    }

    /// Update scorecard
    ///
    /// - Parameters:
    ///   - rankings: Checklist
    ///   - then: Completion
    func update(scorecard: Checklist,
                then: @escaping Completion) {
        guard let status = updated?.updateStatus(scorecard: scorecard),
              status.isPending,
              let userId = user?.id else {
                return then(true)
        }

        net.loadScorecard(list: scorecard,
                          user: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success,
                     .failure(NetworkError.notModified):
                    self.clear(updates: scorecard)
                    then(true)
                default:
                    then(false)
                }
            }
        }
    }

    /// Update page stamp
    ///
    /// - Parameter stamp: Page
    func update(stamp: RankingsPageInfo?) {
        guard let stamp = stamp else { return }
        realm.update(stamp: stamp)
    }
}

// MARK: - Private

private extension DataServiceImpl {

    func withCountry(items: [Checklist.Item],
                     visited: Bool) -> [Checklist.Item] {
        guard items.count == 1,
              items[0].list == .locations,
              let location = get(location: items[0].id) else {
                return items
        }

        if visited {
            if Checklist.uncountries.isVisited(id: location.countryId) {
                return items
            }
        } else if !location.isCountry {
            let children = realm.locations.filter { $0.countryId == location.countryId }
            let visits = self.visited ?? Checked()
            var visitedChildren = 0
            for child in children {
                if visits.locations.contains(child.placeId) {
                    visitedChildren += 1
                }
            }
            if visitedChildren > 1 {
                return items
            }
        }

        let item: Checklist.Item = (list: .uncountries, id: location.countryId)
        return items + [item]
    }

    func children(whs id: Int) -> [WHS] {
        return realm.whss.filter { $0.parentId == id }
    }

    func clear(updates: Checklist) {
        if var update = updated,
            update.clear(scorecard: updates) || update.clear(rankings: updates) {
            updated = update
        }
    }

    #if targetEnvironment(simulator)
    /// Save current data for default startup loading
    func saveRealm() {
        realm.saveToDesktop()
    }
    #endif
}

// MARK: - Testing

#if DEBUG

/// Stub for testing
final class DataServiceStub: DataServiceImpl {

    override var etags: [String: String] {
        get { return [:] }
        // swiftlint:disable:next unused_setter_value
        set { }
    }

    /// Default initializer
    /// Clears fields referenced in UI tests
    override init() {
        super.init()

        blockedPhotos = []
        blockedPosts = []
        blockedUsers = []
        email = ""
    }
}

#endif
