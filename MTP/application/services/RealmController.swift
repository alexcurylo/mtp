// @copyright Trollwerks Inc.

import RealmSwift

// swiftlint:disable file_length

// https://realm.io/docs/swift/latest
// https://realm.io/docs/data-model

// for RealmStudio:
// po Realm.Configuration.defaultConfiguration.fileURL

// swiftlint:disable:next type_body_length
final class RealmController: ServiceProvider {

    private lazy var realm: Realm = createRealm()

    init() {
        #if DEBUG
        defer {
            log.verbose("realm database: \(fileURL)")
        }
        #endif
    }

    var beaches: [Beach] {
        let results = realm.objects(Beach.self)
        return Array(results)
    }

    func set(beaches: [PlaceJSON]) {
        do {
            let objects = beaches.compactMap { Beach(from: $0, with: self) }
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set beaches: \(error)")
        }
    }

    var countries: [Country] {
        let results = realm.objects(Country.self)
        return Array(results)
    }

    func country(id: Int?) -> Country? {
        guard let id = id else { return nil }
        let results = realm.objects(Country.self)
            .filter("countryId = \(id)")
        return results.first
    }

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

    var divesites: [DiveSite] {
        let results = realm.objects(DiveSite.self)
        return Array(results)
    }

    func set(divesites: [PlaceJSON]) {
        do {
            let objects = divesites.compactMap { DiveSite(from: $0, with: self) }
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set divesites: \(error)")
        }
    }

    var golfcourses: [GolfCourse] {
        let results = realm.objects(GolfCourse.self)
        return Array(results)
    }

    func set(golfcourses: [PlaceJSON]) {
        do {
            let objects = golfcourses.compactMap { GolfCourse(from: $0, with: self) }
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set golfcourses: \(error)")
        }
    }

    var locations: [Location] {
        let results = realm.objects(Location.self)
        return Array(results)
    }

    func locations(filter: String) -> [Location] {
        let results = realm.objects(Location.self)
                           .filter(filter)
        return Array(results)
    }

    func location(id: Int?) -> Location? {
        guard let id = id else { return nil }
        let results = realm.objects(Location.self)
                           .filter("id = \(id)")
        return results.first
    }

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

    func photo(id: Int) -> Photo? {
        let filter = "id = \(id)"
        let results = realm.objects(Photo.self)
                           .filter(filter)
        return results.first
    }

    func photos(location: Int) -> [Photo] {
        let filter = "locationId = \(location)"
        let results = realm.objects(Photo.self)
                           .filter(filter)
                           .sorted(byKeyPath: "updatedAt", ascending: false)
        return Array(results)
    }

    func photos(user id: Int,
                location: Int) -> [Photo] {
        let filter = "userId = \(id) AND locationId = \(location)"
        let results = realm.objects(Photo.self)
                           .filter(filter)
                           .sorted(byKeyPath: "updatedAt", ascending: false)
        return Array(results)
    }

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

    func photosPages(user id: Int) -> Results<PhotosPageInfo> {
        let filter = "userId = \(id)"
        let results = realm.objects(PhotosPageInfo.self)
                           .filter(filter)
                           .sorted(byKeyPath: "page")
        return results
    }

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

    func posts(location id: Int) -> [Post] {
        let filter = "locationId = \(id)"
        let results = realm.objects(Post.self)
                           .filter(filter)
                           .sorted(byKeyPath: "updatedAt", ascending: false)
        return Array(results)
    }

    func posts(user id: Int) -> [Post] {
        let filter = "userId = \(id)"
        let results = realm.objects(Post.self)
                           .filter(filter)
                           .sorted(byKeyPath: "updatedAt", ascending: false)
        return Array(results)
    }

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

    func set(posts: [PostJSON]) {
        do {
            let objects = posts.compactMap { Post(from: $0) }
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set posts: \(error)")
        }
    }

    func rankings(query: RankingsQuery) -> Results<RankingsPageInfo> {
        let filter = "queryKey = '\(query.queryKey)'"
        let results = realm.objects(RankingsPageInfo.self)
                           .filter(filter)
                           .sorted(byKeyPath: "page")
        return results
    }

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

    var restaurants: [Restaurant] {
        let results = realm.objects(Restaurant.self)
        return Array(results)
    }

    func set(restaurants: [RestaurantJSON]) {
        do {
            let objects = restaurants.compactMap { Restaurant(from: $0, with: self) }
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set restaurants: \(error)")
        }
    }

    func scorecard(list: Checklist, id: Int) -> Scorecard? {
        let key = Scorecard.key(list: list, user: id)
        let results = realm.objects(Scorecard.self)
                           .filter("dbKey = \(key)")
        return results.first
    }

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

    var uncountries: [UNCountry] {
        let results = realm.objects(UNCountry.self)
        return Array(results)
    }

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

    func user(id: Int) -> User? {
        let results = realm.objects(User.self)
                           .filter("id = \(id)")
        return results.first
    }

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

    var whss: [WHS] {
        let results = realm.objects(WHS.self)
        return Array(results)
    }

    func whs(id: Int) -> WHS? {
        let results = realm.objects(WHS.self)
                           .filter("id = \(id)")
        return results.first
    }

    func set(whss: [WHSJSON]) {
        do {
            let objects = whss.compactMap { WHS(from: $0, with: self) }
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            log.error("set whss: \(error)")
        }
    }
}

private extension RealmController {

    func createRealm() -> Realm {
        // swiftlint:disable:next trailing_closure
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                switch oldSchemaVersion {
                case 0:
                    migration.migrate0to1()
                    // swiftlint:disable:next fallthrough
                    fallthrough
                case 1:
                    migration.migrate1to2()
                default:
                    break
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config

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
        enumerateObjects(ofType: Beach.className()) { _, new in
            new?["website"] = ""
        }
        enumerateObjects(ofType: DiveSite.className()) { _, new in
            new?["website"] = ""
        }
        enumerateObjects(ofType: GolfCourse.className()) { _, new in
            new?["website"] = ""
        }
        enumerateObjects(ofType: Restaurant.className()) { _, new in
            new?["website"] = ""
        }
    }

    func migrate1to2() {
        enumerateObjects(ofType: Photo.className()) { _, new in
            new?["desc"] = ""
        }
    }
}
