// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

protocol PlaceInfo {

    var placeCoordinate: CLLocationCoordinate2D { get }
    var placeCountry: String { get }
    var placeId: Int { get }
    var placeImage: String { get }
    var placeIsCountry: Bool { get }
    var placeIsMappable: Bool { get }
    var placeLocation: Location? { get }
    var placeParent: PlaceInfo? { get }
    var placeRegion: String { get }
    var placeSubtitle: String { get }
    var placeTitle: String { get }
    var placeVisitors: Int { get }
}

// swiftlint:disable:next static_operator
func == (lhs: PlaceInfo, rhs: PlaceInfo) -> Bool {
    return lhs.placeCoordinate == rhs.placeCoordinate &&
           lhs.placeCountry == rhs.placeCountry &&
           lhs.placeId == rhs.placeId &&
           lhs.placeImage == rhs.placeImage &&
           lhs.placeRegion == rhs.placeRegion &&
           lhs.placeSubtitle == rhs.placeSubtitle &&
           lhs.placeTitle == rhs.placeTitle &&
           lhs.placeVisitors == rhs.placeVisitors
}

extension PlaceInfo {

    var placeIsMappable: Bool {
        return true
    }

    var placeParent: PlaceInfo? {
        return nil
    }

    var placeSubtitle: String {
        return placeLocation?.description ?? ""
    }

    var placeIsCountry: Bool {
        return false
    }
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
    dynamic var placeImage: String = ""
    dynamic var placeLocation: Location?
    dynamic var placeVisitors: Int = 0
    dynamic var regionName: String = ""
    dynamic var title: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init?(from: PlaceJSON,
                      with controller: RealmController) {
        guard from.active == "Y" else {
            return nil
        }
        self.init()

        countryName = placeLocation?.countryName ?? Localized.unknown()
        id = from.id
        lat = from.lat
        long = from.long
        placeImage = from.img ?? ""
        placeLocation = controller.location(id: from.location.id)
        placeVisitors = from.visitors
        regionName = placeLocation?.regionName ?? Localized.unknown()
        title = from.title
    }

    override var description: String {
        return title
    }
}

extension Beach: PlaceInfo {

    var placeCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat,
            longitude: long
        )
    }

    var placeCountry: String {
        return countryName
    }

    var placeId: Int {
        return id
    }

    var placeRegion: String {
        return regionName
    }

    var placeTitle: String {
        return title
    }
}

@objcMembers final class DiveSite: Object {

    dynamic var countryName: String = ""
    dynamic var id: Int = 0
    dynamic var lat: Double = 0
    dynamic var long: Double = 0
    dynamic var placeImage: String = ""
    dynamic var placeLocation: Location?
    dynamic var placeVisitors: Int = 0
    dynamic var regionName: String = ""
    dynamic var title: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init?(from: PlaceJSON,
                      with controller: RealmController) {
        guard from.active == "Y" else {
            return nil
        }
        self.init()

        countryName = placeLocation?.countryName ?? Localized.unknown()
        id = from.id
        lat = from.lat
        long = from.long
        placeImage = from.img ?? ""
        placeLocation = controller.location(id: from.location.id)
        placeVisitors = from.visitors
        regionName = placeLocation?.regionName ?? Localized.unknown()
        title = from.title
    }

    override var description: String {
        return title
    }
}

extension DiveSite: PlaceInfo {

    var placeCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat,
            longitude: long
        )
    }

    var placeCountry: String {
        return countryName
    }

    var placeId: Int {
        return id
    }

    var placeRegion: String {
        return regionName
    }

    var placeTitle: String {
        return title
    }
}

@objcMembers final class GolfCourse: Object {

    dynamic var countryName: String = ""
    dynamic var id: Int = 0
    dynamic var lat: Double = 0
    dynamic var long: Double = 0
    dynamic var placeImage: String = ""
    dynamic var placeLocation: Location?
    dynamic var placeVisitors: Int = 0
    dynamic var regionName: String = ""
    dynamic var title: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init?(from: PlaceJSON,
                      with controller: RealmController) {
        guard from.active == "Y" else {
            return nil
        }
        self.init()

        countryName = placeLocation?.countryName ?? Localized.unknown()
        id = from.id
        lat = from.lat
        long = from.long
        placeImage = from.img ?? ""
        placeLocation = controller.location(id: from.location.id)
        placeVisitors = from.visitors
        regionName = placeLocation?.regionName ?? Localized.unknown()
        title = from.title
    }

    override var description: String {
        return title
    }
}

extension GolfCourse: PlaceInfo {

    var placeCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat,
            longitude: long
        )
    }

    var placeCountry: String {
        return countryName
    }

    var placeId: Int {
        return id
    }

    var placeRegion: String {
        return regionName
    }

    var placeTitle: String {
        return title
    }
}
