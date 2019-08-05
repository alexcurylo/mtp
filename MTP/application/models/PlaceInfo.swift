// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

/// Information common to all place types
protocol PlaceInfo {

    /// Coordinate for plotting on map
    var placeCoordinate: CLLocationCoordinate2D { get }
    /// UN country containing place
    var placeCountry: String { get }
    /// Country's MTP ID
    var placeCountryId: Int { get }
    /// Place's MTP ID
    var placeId: Int { get }
    /// UUID of main image to display for place
    var placeImageUrl: URL? { get }
    /// Whether the place is a country
    var placeIsCountry: Bool { get }
    /// MTP location containing place
    var placeLocation: Location? { get }
    /// For WHS, whether place has a parent place
    var placeParent: PlaceInfo? { get }
    /// Region containing the country
    var placeRegion: String { get }
    /// Subtitle to display to user
    var placeSubtitle: String { get }
    /// Title to display to user
    var placeTitle: String { get }
    /// Number of MTP visitors
    var placeVisitors: Int { get }
    /// for non-MTP locations, page to load in More Info screen
    var placeWebUrl: URL? { get }
}

/// Equality operator for PlaceInfos
///
/// - Parameters:
///   - lhs: A PlaceInfo
///   - rhs: Another PlaceInfo
/// - Returns: Whether they are equivalent
func == (lhs: PlaceInfo, rhs: PlaceInfo) -> Bool {
// swiftlint:disable:previous static_operator
    return lhs.placeCoordinate == rhs.placeCoordinate &&
           lhs.placeCountry == rhs.placeCountry &&
           lhs.placeId == rhs.placeId &&
           lhs.placeRegion == rhs.placeRegion &&
           lhs.placeSubtitle == rhs.placeSubtitle &&
           lhs.placeTitle == rhs.placeTitle &&
           lhs.placeVisitors == rhs.placeVisitors
}

extension PlaceInfo {

    /// Only WHS may have parents
    var placeParent: PlaceInfo? {
        return nil
    }

    /// Subtitle is usually the MTP location
    var placeSubtitle: String {
        return placeLocation?.description ?? ""
    }

    /// Only countries are countries
    var placeIsCountry: Bool {
        return false
    }

    /// Default non-countries to 0
    var placeCountryId: Int {
        return 0
    }
}

/// Place info received from MTP endpoints
struct PlaceJSON: Codable {

    fileprivate let active: String
    private let address: String?
    private let country: String
    /// UUID of main image
    let featuredImg: String?
    let id: Int
    let lat: Double
    let location: PlaceLocation
    private let locationId: Int
    let long: Double
    private let notes: String?
    private let rank: Int
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

/// Realm representation of a beach place
@objcMembers final class Beach: Object, PlaceInfo, PlaceMappable {

    /// Link to the Mappable object for this location
    dynamic var map: Mappable?
    dynamic var placeId: Int = 0

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "placeId"
    }

    /// Constructor from MTP endpoint data
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

/// Realm representation of a dive site place
@objcMembers final class DiveSite: Object, PlaceInfo, PlaceMappable {

    /// Link to the Mappable object for this location
    dynamic var map: Mappable?
    dynamic var placeId: Int = 0

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "placeId"
    }

    /// Constructor from MTP endpoint data
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

/// Realm representation of a golf course place
@objcMembers final class GolfCourse: Object, PlaceInfo, PlaceMappable {

    /// Link to the Mappable object for this location
    dynamic var map: Mappable?
    dynamic var placeId: Int = 0

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "placeId"
    }

    /// Constructor from MTP endpoint data
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
