// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

protocol PlaceInfo {

    var placeCountry: String { get }
    var placeId: Int { get }
    var placeName: String { get }
    var placeRegion: String { get }
}

struct PlaceJSON: Codable {

    let active: String
    let address: String?
    let country: String
    let id: Int
    let img: String?
    let lat: Double
    let location: PlaceLocation
    let locationId: Int
    let long: Double
    let notes: String?
    let rank: Int
    let title: String
    let url: String
    let visitors: Int
}

extension PlaceJSON: CustomStringConvertible {

    public var description: String {
        return title
    }
}

extension PlaceJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PlaceJSON: \(description):
        active: \(active)
        address: \(String(describing: address))
        country: \(country)
        id: \(id)
        img: \(String(describing: img))
        lat: \(lat)
        location: \(location)
        locationId: \(locationId)
        long: \(long)
        notes: \(String(describing: notes))
        rank: \(rank)
        title: \(title)
        url: \(url)
        visitors: \(visitors)
        /PlaceJSON >
        """
    }
}

@objcMembers final class Beach: Object {

    dynamic var countryName: String = ""
    dynamic var id: Int = 0
    dynamic var lat: Double = 0
    dynamic var long: Double = 0
    dynamic var regionName: String = ""
    dynamic var title: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(from: PlaceJSON) {
        self.init()

        countryName = from.location.countryName
        id = from.id
        lat = from.lat
        long = from.long
        regionName = from.location.regionName
        title = from.title
    }

    override var description: String {
        return title
    }
}

extension Beach: PlaceInfo {

    var placeCountry: String {
        return countryName
    }

    var placeId: Int {
        return id
    }

    var placeName: String {
        return title
    }

    var placeRegion: String {
        return regionName
    }
}

extension Beach {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat,
            longitude: long
        )
    }

    var subtitle: String { return "" }
}

@objcMembers final class DiveSite: Object {

    dynamic var countryName: String = ""
    dynamic var id: Int = 0
    dynamic var lat: Double = 0
    dynamic var long: Double = 0
    dynamic var regionName: String = ""
    dynamic var title: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(from: PlaceJSON) {
        self.init()

        countryName = from.location.countryName
        id = from.id
        lat = from.lat
        long = from.long
        regionName = from.location.regionName
        title = from.title
    }

    override var description: String {
        return title
    }
}

extension DiveSite: PlaceInfo {

    var placeCountry: String {
        return countryName
    }

    var placeId: Int {
        return id
    }

    var placeName: String {
        return title
    }

    var placeRegion: String {
        return regionName
    }
}

extension DiveSite {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat,
            longitude: long
        )
    }

    var subtitle: String { return "" }
}

@objcMembers final class GolfCourse: Object {

    dynamic var countryName: String = ""
    dynamic var id: Int = 0
    dynamic var lat: Double = 0
    dynamic var long: Double = 0
    dynamic var regionName: String = ""
    dynamic var title: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(from: PlaceJSON) {
        self.init()

        countryName = from.location.countryName
        id = from.id
        lat = from.lat
        long = from.long
        regionName = from.location.regionName
        title = from.title
    }

    override var description: String {
        return title
    }
}

extension GolfCourse: PlaceInfo {

    var placeCountry: String {
        return countryName
    }

    var placeId: Int {
        return id
    }

    var placeName: String {
        return title
    }

    var placeRegion: String {
        return regionName
    }
}

extension GolfCourse {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat,
            longitude: long
        )
    }

    var subtitle: String { return "" }
}
