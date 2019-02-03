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
            log.error("set locations: \(error)")
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
