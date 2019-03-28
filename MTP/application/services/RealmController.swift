// @copyright Trollwerks Inc.

import RealmSwift

// https://realm.io/docs/swift/latest
// https://realm.io/docs/data-model

// swiftlint:disable:next type_body_length
final class RealmController: ServiceProvider {

    private lazy var realm: Realm = {
        do {
            let folder = fileURL.deletingLastPathComponent().path
            let noLocking = [FileAttributeKey.protectionKey: FileProtectionType.none]
            try FileManager.default.setAttributes(noLocking, ofItemAtPath: folder)
            return try Realm()
        } catch(let error as NSError) where error.code == 10 {
            // for now, reset instead of migrating
            deleteDatabaseFiles()
            // swiftlint:disable:next force_try
            return try! Realm()
        } catch {
            let message = "creating realm: \(error)"
            log.error(message)
            fatalError(message)
        }
    }()

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
                realm.add(objects, update: true)
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
                realm.add(Country.all, update: true)
                realm.add(objects, update: true)
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
                realm.add(objects, update: true)
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
                realm.add(objects, update: true)
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
                realm.add(Location.all, update: true)
                realm.add(objects, update: true)
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

    func photos(user id: Int,
                location: Int) -> [Photo] {
        let filter = "userId = \(id) AND locationId = \(location)"
        let results = realm.objects(Photo.self)
                           .filter(filter)
                           .sorted(byKeyPath: "updatedAt", ascending: false)
        return Array(results)
    }

    func set(photos page: Int,
             user: Int?,
             info: PhotosPageInfoJSON) {
        do {
            let page = PhotosPageInfo(user: user, info: info)
            let photos = info.data.map { Photo(from: $0) }
            try realm.write {
                realm.add(page, update: true)
                realm.add(photos, update: true)
            }
        } catch {
            log.error("update photos:page: \(error)")
        }
    }

    func photosPages(user id: Int?) -> Results<PhotosPageInfo> {
        let queryKey = PhotosPageInfo.key(user: id)
        let filter = "queryKey = '\(queryKey)'"
        let results = realm.objects(PhotosPageInfo.self)
                           .filter(filter)
                           .sorted(byKeyPath: "page")
        return results
    }

    func deleteUserPhotos() {
        do {
            let queryKey = PhotosPageInfo.key(user: nil)
            let filter = "queryKey = '\(queryKey)'"
            let results = realm.objects(PhotosPageInfo.self)
                .filter(filter)
            try realm.write {
                realm.delete(results)
            }
        } catch {
            log.error("deleteUserPhotos: \(error)")
        }
    }

    var posts: [Post] {
        let results = realm.objects(Post.self)
                           .sorted(byKeyPath: "updatedAt", ascending: false)
        return Array(results)
    }

    func set(posts: [PostJSON]) {
        do {
            let objects = posts.compactMap { Post(from: $0) }
            try realm.write {
                realm.delete(realm.objects(Post.self))
                realm.add(objects, update: true)
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
                realm.add(page, update: true)
                realm.add(users, update: true)
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
                realm.add(objects, update: true)
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
                realm.add(object, update: true)
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
                realm.add(objects, update: true)
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
                realm.add(object, update: true)
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
                realm.add(objects, update: true)
            }
        } catch {
            log.error("set whss: \(error)")
        }
    }
}

private extension RealmController {

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
