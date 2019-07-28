// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

protocol PlaceInfo {

    var placeCoordinate: CLLocationCoordinate2D { get }
    var placeCountry: String { get }
    var placeCountryId: Int { get }
    var placeId: Int { get }
    var placeImageUrl: URL? { get }
    var placeIsCountry: Bool { get }
    var placeLocation: Location? { get }
    var placeParent: PlaceInfo? { get }
    var placeRegion: String { get }
    var placeSubtitle: String { get }
    var placeTitle: String { get }
    var placeVisitors: Int { get }
    var placeWebUrl: URL? { get }
}

// swiftlint:disable:next static_operator
func == (lhs: PlaceInfo, rhs: PlaceInfo) -> Bool {
    return lhs.placeCoordinate == rhs.placeCoordinate &&
           lhs.placeCountry == rhs.placeCountry &&
           lhs.placeId == rhs.placeId &&
           lhs.placeRegion == rhs.placeRegion &&
           lhs.placeSubtitle == rhs.placeSubtitle &&
           lhs.placeTitle == rhs.placeTitle &&
           lhs.placeVisitors == rhs.placeVisitors
}

extension PlaceInfo {

    var placeParent: PlaceInfo? {
        return nil
    }

    var placeSubtitle: String {
        return placeLocation?.description ?? ""
    }

    var placeIsCountry: Bool {
        return false
    }

    var placeCountryId: Int {
        return 0
    }
}

struct PlaceJSON: Codable {

    let active: String
    let address: String?
    let country: String
    let featuredImg: String?
    let id: Int
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
        featuredImg: \(String(describing: featuredImg))
        id: \(id)
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

@objcMembers final class Beach: Object, PlaceInfo, PlaceMappable {

    dynamic var map: Mappable?
    dynamic var placeId: Int = 0

    override static func primaryKey() -> String? {
        return "placeId"
    }

    convenience init?(from: PlaceJSON,
                      realm: RealmDataController) {
        guard from.active == "Y" else { return nil }
        self.init()

        map = Mappable(checklist: .beaches,
                       place: from,
                       realm: realm)
        placeId = from.id
    }

    override var description: String {
        return placeTitle
    }
}

@objcMembers final class DiveSite: Object, PlaceInfo, PlaceMappable {

    dynamic var map: Mappable?
    dynamic var placeId: Int = 0

    override static func primaryKey() -> String? {
        return "placeId"
    }

    convenience init?(from: PlaceJSON,
                      realm: RealmDataController) {
        guard from.active == "Y" else { return nil }
        self.init()

        map = Mappable(checklist: .divesites,
                       place: from,
                       realm: realm)
        placeId = from.id
    }

    override var description: String {
        return placeTitle
    }
}

@objcMembers final class GolfCourse: Object, PlaceInfo, PlaceMappable {

    dynamic var map: Mappable?
    dynamic var placeId: Int = 0

    override static func primaryKey() -> String? {
        return "placeId"
    }

    convenience init?(from: PlaceJSON,
                      realm: RealmDataController) {
        guard from.active == "Y" else { return nil }
        self.init()

        map = Mappable(checklist: .golfcourses,
                       place: from,
                       realm: realm)
        placeId = from.id
    }

    override var description: String {
        return placeTitle
    }
}
