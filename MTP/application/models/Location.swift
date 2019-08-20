// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

/// Type of location
enum AdminLevel: Int {

    /// Unknown
    case unknown = 0
    /// A UN country
    case country = 2
    /// An MTP location
    case location = 4
}

/// Location info received from MTP endpoints
struct LocationJSON: Codable, Equatable {

    /// Filter for current data
    let active: String
    fileprivate let adminLevel: Int
    fileprivate let airports: String?
    /// Unique ID of country
    /// null or 0 in index 190-192 of un-country
    let countryId: Int?
    /// Name to display in UI
    let countryName: String
    private let distance: Double?
    /// UUID of main image
    fileprivate let featuredImg: String?
    /// Unique ID of location
    let id: Int
    private let isMtpLocation: Int
    private let isUn: Int
    fileprivate let lat: Double?
    fileprivate let locationName: String
    fileprivate let lon: Double?
    fileprivate let rank: Int
    fileprivate let rankUn: Int
    private let regionId: Int
    /// Region containing this country
    let regionName: String
    /// Number of MTP visitors
    let visitors: Int
    private let visitorsUn: Int
    private let weather: String?
    fileprivate let weatherhist: String?
    private let zoom: Int?
}

extension LocationJSON: CustomStringConvertible {

    var description: String {
        if !countryName.isEmpty
           && !locationName.isEmpty
           && countryName != locationName {
            return L.locationDescription(locationName, countryName)
        }
        return locationName.isEmpty ? countryName : locationName
    }
}

extension LocationJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < LocationJSON: \(description):
        active: \(active)
        admin_level: \(adminLevel)
        airports: \(String(describing: airports))
        countryId: \(String(describing: countryId))
        countryName: \(countryName)
        distance: \(String(describing: distance))
        featuredImg: \(String(describing: featuredImg))
        id: \(id)
        is_mtp_location: \(isMtpLocation)
        is_un: \(isUn)
        lat: \(String(describing: lat))
        location_name: \(locationName)
        lon: \(String(describing: lon))
        rank: \(rank)
        rankUn: \(rankUn)
        region_id: \(regionId)
        region_name: \(regionName)
        visitors: \(visitors)
        visitorsUn: \(visitorsUn)
        weather: \(String(describing: weather))
        weatherhist: \(String(describing: weatherhist))
        zoom: \(String(describing: zoom))
        /LocationJSON >
        """
    }
}

/// Realm representation of a MTP location
@objcMembers final class Location: Object, PlaceMappable, ServiceProvider {

    /// Link to the Mappable object for this location
    dynamic var map: Mappable?

    /// Whether this is a country or a location
    dynamic var adminLevel: Int = 0
    /// Airports to be found in this location
    dynamic var airports: String = ""
    /// Country ID
    dynamic var countryId: Int = 0
    /// Description of country
    dynamic var placeCountry: String = ""
    /// Place's MTP ID
    dynamic var placeId: Int = 0
    /// Region containing the country
    dynamic var placeRegion: String = ""
    /// Title to display to user
    dynamic var placeTitle: String = ""
    /// Difficulty rank of location
    dynamic var rank: Int = 0
    /// Difficulty rank of UN country
    dynamic var rankUn: Int = 0
    /// For use in constructing weather information URL
    dynamic var weatherhist: String = ""

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "placeId"
    }

    /// Constructor from MTP endpoint data
    convenience init?(from: LocationJSON) {
        guard from.active == "Y",
              let country = from.countryId,
              country > 0 else { return nil }
        self.init()

        adminLevel = from.adminLevel
        let subtitle = isCountry ? from.regionName : from.countryName
        let website = "https://mtp.travel/locations/\(from.id)"
        map = Mappable(checklist: .locations,
                       checklistId: from.id,
                       country: from.locationName,
                       image: from.featuredImg ?? "",
                       latitude: from.lat ?? 0,
                       location: self,
                       longitude: from.lon ?? 0,
                       region: from.regionName,
                       subtitle: subtitle,
                       title: from.locationName,
                       visitors: from.visitors,
                       website: website)

        airports = from.airports ?? ""
        countryId = country
        placeCountry = from.countryName
        placeId = from.id
        placeRegion = from.regionName
        placeTitle = from.locationName
        rank = from.rank
        rankUn = from.rankUn
        weatherhist = from.weatherhist ?? ""
    }

    /// Placeholder for selection screens
    static var all: Location = {
        let all = Location()
        all.placeCountry = L.allCountries()
        all.placeRegion = L.allRegions()
        return all
    }()

    override var description: String {
        guard map != nil else {
            return L.allLocations()
        }

        let placeName = placeTitle
        if !placeCountry.isEmpty
           && !placeName.isEmpty
           && placeCountry != placeName {
            return L.locationDescription(placeName, placeCountry)
        }
        return placeName.isEmpty ? placeCountry : placeName
    }

    /// Equality operator
    ///
    /// - Parameter object: Other object
    /// - Returns: equality
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Location else { return false }
        guard !isSameObject(as: other) else { return true }

        return countryId == other.countryId &&
               placeCountry == other.placeCountry &&
               placeId == other.placeId &&
               placeRegion == other.placeRegion &&
               placeTitle == other.placeTitle
    }
}

extension Location: PlaceInfo {

    /// Country's MTP ID
    var placeCountryId: Int {
        return countryId
    }

    /// MTP location containing place
    var placeLocation: Location? {
        return self
    }

    /// Subtitle to display to user
    var placeSubtitle: String {
        return map?.subtitle ?? ""
    }

    /// Special cases to treat as if they're flattenable
    enum Inexpandibles: Int {
        /// Europe: Netherlands (mainland)
        case netherlandsMainland = 301
        /// Europe: Portugal (mainland)
        case portugalMainland = 305
        /// Europe: Turkey (Thrace)
        case turkishThrace = 325
    }

    /// Whether the place is a country
    var placeIsCountry: Bool {
        switch placeId {
        case Inexpandibles.netherlandsMainland.rawValue,
             Inexpandibles.portugalMainland.rawValue,
             Inexpandibles.turkishThrace.rawValue:
            return true
        default:
            return isCountry
        }
    }
}

extension Location {

    /// URL of flag image
    var flagUrl: URL? {
        let link = "https://mtp.travel/flags/\(countryId)"
        return URL(string: link)
    }

    /// Whether location is country
    var isCountry: Bool {
        return AdminLevel(rawValue: adminLevel) == .country
    }

    /// Map marker latitude
    var latitude: CLLocationDegrees {
        return map?.latitude ?? 0
    }

    /// Map marker longitude
    var longitude: CLLocationDegrees {
        return map?.longitude ?? 0
    }
}
