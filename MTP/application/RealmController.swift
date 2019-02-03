// @copyright Trollwerks Inc.

import RealmSwift

// https://realm.io/docs/swift/latest
// https://realm.io/docs/data-model

// Direct JSON decoding to Object notes:
// https://github.com/Kaakati/Realm-and-Swift-Codable
// https://stackoverflow.com/questions/45452833/how-to-use-list-type-with-codable-realmswift
// https://stackoverflow.com/questions/53332732/how-to-implement-codable-while-using-realm
// https://stackoverflow.com/questions/52742525/merge-a-realm-and-codable-class-in-swift-4
// https://stackoverflow.com/questions/51302029/how-to-make-the-realmswift-realmoptional-compatible-with-swift-codable

final class RealmController: ServiceProvider {

    private lazy var realm: Realm = {
        do {
            let folder = fileURL.deletingLastPathComponent().path
            let noLocking = [FileAttributeKey.protectionKey: FileProtectionType.none]
            try FileManager.default.setAttributes(noLocking, ofItemAtPath: folder)
            return try Realm()
        } catch {
            let message = "creating realm: \(error)"
            log.error(message)
            fatalError(message)
        }
    }()

    init() {
        //deleteDatabaseFiles()

        // swiftlint:disable:next inert_defer
        defer {
            log.verbose("realm database: \(fileURL)")
        }
    }

    var beaches: [Beach] {
        let results = realm.objects(Beach.self)
        return Array(results)
    }

    func set(beaches: [PlaceJSON]) {
        do {
            let objects = beaches.map { Beach(from: $0) }
            try realm.write {
                realm.add(objects, update: true)
            }
        } catch {
            log.error("set beaches: \(error)")
        }
    }

    var divesites: [DiveSite] {
        let results = realm.objects(DiveSite.self)
        return Array(results)
    }

    func set(divesites: [PlaceJSON]) {
        do {
            let objects = divesites.map { DiveSite(from: $0) }
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
            let objects = golfcourses.map { GolfCourse(from: $0) }
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

    func location(id: Int) -> Location? {
        let results = realm.objects(Location.self).filter("id = \(id)")
        return results.first
    }

    func set(locations: [LocationJSON]) {
        do {
            let objects = locations.map { Location(from: $0) }
            try realm.write {
                realm.add(objects, update: true)
            }
        } catch {
            log.error("set locations: \(error)")
        }
    }

    var restaurants: [Restaurant] {
        let results = realm.objects(Restaurant.self)
        return Array(results)
    }

    func set(restaurants: [RestaurantJSON]) {
        do {
            let objects = restaurants.map { Restaurant(from: $0, with: self) }
            try realm.write {
                realm.add(objects, update: true)
            }
        } catch {
            log.error("set restaurants: \(error)")
        }
    }

    var uncountries: [UNCountry] {
        let results = realm.objects(UNCountry.self)
        return Array(results)
    }

    func set(uncountries: [LocationJSON]) {
        do {
            let objects = uncountries.map { UNCountry(from: $0) }
            try realm.write {
                realm.add(objects, update: true)
            }
        } catch {
            log.error("set uncountries: \(error)")
        }
    }

    func user(id: Int) -> User? {
        let results = realm.objects(User.self).filter("id = \(id)")
        return results.first
    }

    func set(userId: UserJSON) {
        do {
            let object = User(from: userId)
            try realm.write {
                realm.add(object, update: true)
            }
        } catch {
            log.error("set userIds: \(error)")
        }
    }

    func set(userIds: [RankedUserJSON]) {
        do {
            let objects = userIds.map { User(from: $0) }
            try realm.write {
                realm.add(objects, update: true)
            }
        } catch {
            log.error("set userIds: \(error)")
        }
    }

    var whss: [WHS] {
        let results = realm.objects(WHS.self)
        return Array(results)
    }

    func set(whss: [WHSJSON]) {
        do {
            let objects = whss.map { WHS(from: $0) }
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
