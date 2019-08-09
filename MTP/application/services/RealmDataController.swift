// @copyright Trollwerks Inc.

import RealmSwift

// swiftlint:disable file_length

// https://realm.io/docs/swift/latest

/// Wrapper around Realm database
final class RealmDataController: ServiceProvider {
    // swiftlint:disable:previous type_body_length

    private lazy var realm: Realm = create()

    /// Default initializer
    init() {
        configure()
        seed()
    }

    /// Beaches
    var beaches: [Beach] {
        let results = realm.objects(Beach.self)
        return Array(results)
    }

    /// Set beaches
    ///
    /// - Parameter beaches: API results
    func set(beaches: [PlaceJSON]) {
        do {
            let objects = beaches.compactMap { Beach(from: $0, realm: self) }
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set beaches: \(error)")
        }
    }

    /// Countries
    var countries: [Country] {
        let results = realm.objects(Country.self)
        return Array(results)
    }

    /// Get country
    ///
    /// - Parameter id: country ID
    /// - Returns: Country if found
    func country(id: Int?) -> Country? {
        guard let id = id else { return nil }
        let results = realm.objects(Country.self)
                           .filter("countryId = \(id)")
        return results.first
    }

    /// Set countries
    ///
    /// - Parameter countries: API results
    func set(countries: [CountryJSON]) {
        do {
            let objects = countries.map { Country(from: $0) }
            try realm.write {
                realm.add(Country.all, update: .modified)
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set countries: \(error)")
        }
    }

    /// Dive sites
    var divesites: [DiveSite] {
        let results = realm.objects(DiveSite.self)
        return Array(results)
    }

    /// Set dive sites
    ///
    /// - Parameter divesites: API results
    func set(divesites: [PlaceJSON]) {
        do {
            let objects = divesites.compactMap { DiveSite(from: $0, realm: self) }
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set divesites: \(error)")
        }
    }

    /// Golf courses
    var golfcourses: [GolfCourse] {
        let results = realm.objects(GolfCourse.self)
        return Array(results)
    }

    /// Set golf courses
    ///
    /// - Parameter golfcourses: API results
    func set(golfcourses: [PlaceJSON]) {
        do {
            let objects = golfcourses.compactMap { GolfCourse(from: $0, realm: self) }
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set golfcourses: \(error)")
        }
    }

    /// Locations
    var locations: [Location] {
        let results = realm.objects(Location.self)
        return Array(results)
    }

    /// Get filtered locations
    ///
    /// - Parameter filter: Filter
    /// - Returns: Locations if found
    func locations(filter: String) -> [Location] {
        let results = realm.objects(Location.self)
                           .filter(filter)
        return Array(results)
    }

    /// Get location
    ///
    /// - Parameter id: location ID
    /// - Returns: Location if found
    func location(id: Int?) -> Location? {
        guard let id = id else { return nil }
        let results = realm.objects(Location.self)
                           .filter("placeId = \(id)")
        return results.first
    }

    /// Set locations
    ///
    /// - Parameter locations: API results
    func set(locations: [LocationJSON]) {
        do {
            let objects = locations.compactMap { Location(from: $0) }
            try realm.write {
                realm.add(Location.all, update: .modified)
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set locations: \(error)")
        }
    }

    /// Get place
    ///
    /// - Parameter item: list and ID
    /// - Returns: Place if found
    func mappable(item: Checklist.Item) -> Mappable? {
        let key = Mappable.key(item: item)
        let results = realm.objects(Mappable.self)
                           .filter("dbKey = '\(key)'")
        return results.first
    }

    /// Get places
    ///
    /// - Parameter list: list
    /// - Returns: Places in list
    func mappables(list: Checklist?) -> [Mappable] {
        let results: Results<Mappable>
        if let value = list?.rawValue {
            results = realm.objects(Mappable.self)
                           .filter("checklistValue = \(value)")
       } else {
            results = realm.objects(Mappable.self)
       }
        return Array(results)
    }

    /// Get matching places
    ///
    /// - Parameter matching: String
    /// - Returns: Places matching
    func mappables(matching: String) -> [Mappable] {
        guard !matching.isEmpty else { return [] }

        let filter = "title contains[cd] '\(matching)'"
        let results = realm.objects(Mappable.self)
                           .filter(filter)
        return Array(results)
    }

    /// Get milestones
    ///
    /// - Parameter list: Checklist
    /// - Returns: Milestones if found
    func milestones(list: Checklist) -> Milestones? {
        let results = realm.objects(Milestones.self)
                           .filter("checklistValue = \(list.rawValue)")
        return results.first
    }

    /// Set milestones
    ///
    /// - Parameter milestones: API results
    func set(milestones: SettingsJSON) {
        do {
            let objects = Checklist.allCases.map {
                Milestones(from: milestones,
                           list: $0)
            }
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set milestones: \(error)")
        }
    }

    /// Get photo
    ///
    /// - Parameter id: ID
    /// - Returns: Photo
    func photo(id: Int) -> Photo? {
        let filter = "photoId = \(id)"
        let results = realm.objects(Photo.self)
                           .filter(filter)
        return results.first
    }

    /// Get location photos
    ///
    /// - Parameter id: location ID
    /// - Returns: Photos if found
    func photos(location: Int) -> [Photo] {
        let filter = "locationId = \(location)"
        let results = realm.objects(Photo.self)
                           .filter(filter)
                           .sorted(byKeyPath: "updatedAt", ascending: false)
        return Array(results)
    }

    /// Get user photos by location
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - location: Location
    /// - Returns: Photos if found
    func photos(user id: Int,
                location: Int) -> [Photo] {
        let filter = "userId = \(id) AND locationId = \(location)"
        let results = realm.objects(Photo.self)
                           .filter(filter)
                           .sorted(byKeyPath: "updatedAt", ascending: false)
        return Array(results)
    }

    /// Set location photos
    ///
    /// - Parameters:
    ///   - id: Location ID
    ///   - photos: API results
    func set(locationPhotos id: Int,
             info: PhotosInfoJSON) {
        do {
            let photos = info.data.map { Photo(from: $0) }
            try realm.write {
                realm.add(photos, update: .modified)
            }
        } catch {
            log.error("update locationPhotos: \(error)")
        }
    }

    /// Set photo
    ///
    /// - Parameter photo: API result
    func set(photo: PhotoReply) {
        do {
            let new = Photo(from: photo)
            try realm.write {
                realm.add(new, update: .modified)
            }
        } catch {
            log.error("set photo: \(error)")
        }
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
        do {
            let page = PhotosPageInfo(user: id, info: info)
            let photos = info.data.map { Photo(from: $0) }
            try realm.write {
                realm.add(page, update: .modified)
                realm.add(photos, update: .modified)
            }
        } catch {
            log.error("update photos:page: \(error)")
        }
    }

    /// Get user photo pages
    ///
    /// - Parameter id: User ID
    /// - Returns: Photo pages if found
    func photosPages(user id: Int) -> Results<PhotosPageInfo> {
        let filter = "userId = \(id)"
        let results = realm.objects(PhotosPageInfo.self)
                           .filter(filter)
                           .sorted(byKeyPath: "page")
        return results
    }

    /// Delete all user photos
    ///
    /// - Parameter id: User ID
    func deletePhotos(user id: Int) {
        do {
            let filter = "userId = \(id)"
            let results = realm.objects(PhotosPageInfo.self)
                               .filter(filter)
            try realm.write {
                realm.delete(results)
            }
        } catch {
            log.error("deletePhotos: \(error)")
        }
    }

    /// Get location posts
    ///
    /// - Parameter id: location ID
    /// - Returns: Posts if found
    func posts(location id: Int) -> [Post] {
        let filter = "locationId = \(id)"
        let results = realm.objects(Post.self)
                           .filter(filter)
                           .sorted(byKeyPath: "updatedAt", ascending: false)
        return Array(results)
    }

    /// Get user posts
    ///
    /// - Parameter id: User ID
    /// - Returns: Posts if found
    func posts(user id: Int) -> [Post] {
        let filter = "userId = \(id)"
        let results = realm.objects(Post.self)
                           .filter(filter)
                           .sorted(byKeyPath: "updatedAt", ascending: false)
        return Array(results)
    }

    /// Set post
    ///
    /// - Parameter post: API results
    func set(post: PostReply) {
        do {
            guard let new = Post(from: post) else { return }
            try realm.write {
                realm.add(new, update: .modified)
            }
        } catch {
            log.error("set post: \(error)")
        }
    }

    /// Set posts
    ///
    /// - Parameters:
    ///   - id: Location ID
    ///   - posts: API results
    func set(posts: [PostJSON]) {
        do {
            let objects = posts.compactMap { Post(from: $0) }
            let users: [User] = posts.compactMap {
                guard let owner = $0.owner else { return nil }
                return User(from: owner, with: user(id: $0.userId))
            }
            try realm.write {
                if !objects.isEmpty {
                    realm.add(objects, update: .modified)
                }
                if !users.isEmpty {
                    realm.add(users, update: .modified)
                }
            }
        } catch {
            log.error("set posts: \(error)")
        }
    }

    /// Get rankings pages
    ///
    /// - Parameter query: Filter query
    /// - Returns: Rankings pages if found
    func rankings(query: RankingsQuery) -> Results<RankingsPageInfo> {
        let filter = "queryKey = '\(query.queryKey)'"
        let results = realm.objects(RankingsPageInfo.self)
                           .filter(filter)
                           .sorted(byKeyPath: "page")
        return results
    }

    /// Set rankings query
    ///
    /// - Parameters:
    ///   - query: Query
    ///   - info: API results
    func set(rankings query: RankingsQuery,
             info: RankingsPageInfoJSON) {
        do {
            let page = RankingsPageInfo(query: query, info: info)
            let users = info.users.data.map { User(from: $0, with: user(id: $0.id)) }
            try realm.write {
                realm.add(page, update: .modified)
                realm.add(users, update: .modified)
            }
        } catch {
            log.error("update query:page: \(error)")
        }
    }

    /// Restaurants
    var restaurants: [Restaurant] {
        let results = realm.objects(Restaurant.self)
        return Array(results)
    }

    /// Set restaurants
    ///
    /// - Parameter restaurants: API results
    func set(restaurants: [RestaurantJSON]) {
        do {
            let objects = restaurants.compactMap { Restaurant(from: $0, realm: self) }
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set restaurants: \(error)")
        }
    }

    /// Get user scorecard
    ///
    /// - Parameters:
    ///   - list: Checklist
    ///   - id: userID
    /// - Returns: Scorecard if found
    func scorecard(list: Checklist, id: Int) -> Scorecard? {
        let key = Scorecard.key(list: list, user: id)
        let results = realm.objects(Scorecard.self)
                           .filter("dbKey = '\(key)'")
        return results.first
    }

    /// Set scorecard
    ///
    /// - Parameter scorecard: API results
    func set(scorecard: ScorecardWrapperJSON) {
        do {
            let object = Scorecard(from: scorecard)
            try realm.write {
                realm.add(object, update: .modified)
            }
        } catch {
            log.error("set scorecard: \(error)")
        }
    }

    /// UN Countries
    var uncountries: [UNCountry] {
        let results = realm.objects(UNCountry.self)
        return Array(results)
    }

    /// Set UN countries
    ///
    /// - Parameter uncountries: API results
    func set(uncountries: [LocationJSON]) {
        do {
            let objects = uncountries.compactMap { UNCountry(from: $0) }
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set uncountries: \(error)")
        }
    }

    /// Get user
    ///
    /// - Parameter id: User ID
    /// - Returns: User if found
    func user(id: Int) -> User? {
        let results = realm.objects(User.self)
                           .filter("userId = \(id)")
        return results.first
    }

    /// Set user
    ///
    /// - Parameter data: API results
    func set(user data: UserJSON) {
        do {
            let object = User(from: data)
            try realm.write {
                realm.add(object, update: .modified)
            }
        } catch {
            log.error("set userIds: \(error)")
        }
    }

    /// WHSs
    var whss: [WHS] {
        let results = realm.objects(WHS.self)
        return Array(results)
    }

    /// Get WHS
    ///
    /// - Parameter id: WHS ID
    /// - Returns: WHS if found
    func whs(id: Int) -> WHS? {
        let results = realm.objects(WHS.self)
                           .filter("placeId = \(id)")
        return results.first
    }

    /// Set WHSs
    ///
    /// - Parameter whss: API results
    func set(whss: [WHSJSON]) {
        do {
            let objects = whss.compactMap { WHS(from: $0, realm: self) }
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set whss: \(error)")
        }
    }

    /// Resolve Realm crossthread reference
    ///
    /// - Parameter reference: Reference
    /// - Returns: Mappable if found
    func resolve(reference: Mappable.Reference) -> Mappable? {
        return realm.resolve(reference)
    }

    /// Update page stamp
    ///
    /// - Parameter stamp: Page
    func update(stamp: RankingsPageInfo) {
        do {
            try realm.write {
                stamp.stamp()
            }
        } catch {
            log.error("update stamp: \(error)")
        }
    }
}

// MARK: - Private

private extension RealmDataController {

    func configure() {
        // swiftlint:disable:next trailing_closure
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                self.log.verbose("migrating database \(oldSchemaVersion) to 1")
                switch oldSchemaVersion {
                case 0:
                    migration.migrate0to1()
                    // swiftlint:disable:next fallthrough
                    fallthrough
                default:
                    break
                }
            }
        )
        // reset instead of migrating
        //let config = Realm.Configuration(schemaVersion: 0,
                                           //deleteRealmIfMigrationNeeded: true)

        Realm.Configuration.defaultConfiguration = config
    }

    func seed() {
        let fileManager = FileManager.default
        guard !fileManager.fileExists(atPath: fileURL.path),
              let seed = Bundle.main.url(forResource: "default",
                                         withExtension: "realm") else {
            return
        }

        do {
            try fileManager.copyItem(at: seed, to: fileURL)
        } catch {
            #if DEBUG
            ConsoleLoggingService().error("seeding realm: \(error)")
            #endif
        }
    }

    func create() -> Realm {
        do {
            let folder = fileURL.deletingLastPathComponent().path
            let noLocking = [FileAttributeKey.protectionKey: FileProtectionType.none]
            try FileManager.default.setAttributes(noLocking, ofItemAtPath: folder)
            return try Realm()
        } catch (let error as NSError) where error.code == 10 {
            deleteDatabaseFiles()
            // swiftlint:disable:next force_try
            return try! Realm()
        } catch {
            let message = "creating realm: \(error)"
            log.error(message)
            fatalError(message)
        }
    }

    var fileURL: URL {
        // swiftlint:disable:next force_unwrapping
        return Realm.Configuration.defaultConfiguration.fileURL!
    }

    func deleteDatabaseFiles() {
        do {
            try [ fileURL,
                  fileURL.appendingPathExtension("lock"),
                  fileURL.appendingPathExtension("note"),
                  fileURL.appendingPathExtension("management")].forEach {
                try FileManager.default.removeItem(at: $0)
            }
        } catch {
            log.error("deleting realm: \(error)")
        }
    }

    func emptyDatabase() {
        do {
            try realm.write { realm.deleteAll() }
        } catch {
            log.error("emptying realm: \(error)")
        }
    }
}

private extension Migration {

    func migrate0to1() {
        // apply new defaults: https://github.com/realm/realm-cocoa/issues/1793
        enumerateObjects(ofType: RankingsPageInfo.className()) { _, new in
            new?["timestamp"] = 0
        }
    }
}

// MARK: - Seeding

#if targetEnvironment(simulator)
extension RealmDataController {

    /// Save current data for default startup loading
    func saveToDesktop() {
        // po Realm.Configuration.defaultConfiguration.fileURL
        do {
            let home = try unwrap(ProcessInfo.processInfo.environment["SIMULATOR_HOST_HOME"])
            let file = fileURL.lastPathComponent
            let path = "\(home)/Desktop/\(file)"
            let destination = URL(fileURLWithPath: path)
            try realm.writeCopy(toFile: destination)
        } catch {
            ConsoleLoggingService().error("saving realm: \(error)")
        }
    }
}
#endif
