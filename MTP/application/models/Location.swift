// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

enum AdminLevel: Int {
    case country = 2
    case location = 4
}

struct LocationJSON: Codable {

    let active: String
    let adminLevel: Int
    let airports: String?
    let countryId: Int? // null or 0 in index 190-192 of un-country
    let countryName: String
    let distance: Double?
    let featuredImg: String?
    let id: Int
    let isMtpLocation: Int
    let isUn: Int
    let lat: Double?
    let locationName: String
    let lon: Double?
    let rank: Int
    let rankUn: Int
    let regionId: Int
    let regionName: String
    let visitors: Int
    let visitorsUn: Int
    let weather: String?
    let weatherhist: String?
    let zoom: Int?
}

extension LocationJSON: CustomStringConvertible {

    public var description: String {
        if !countryName.isEmpty
            && !locationName.isEmpty
            && countryName != locationName {
            return "\(locationName), \(countryName)"
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

@objcMembers final class Location: Object, ServiceProvider {

    dynamic var countryId: Int = 0
    dynamic var countryName: String = ""
    dynamic var featuredImg: String?
    dynamic var id: Int = 0
    dynamic var lat: Double = 0
    dynamic var locationName: String = ""
    dynamic var lon: Double = 0
    dynamic var regionName: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init?(from: LocationJSON) {
        guard from.active == "Y" else {
            return nil
        }
        self.init()

        guard let country = from.countryId, country > 0 else {
            log.warning("Unexpected \(from.countryName) countryId: \(String(describing: from.countryId))")
            return nil
        }

        countryId = country
        countryName = from.countryName
        featuredImg = from.featuredImg
        id = from.id
        lat = from.lat ?? 0
        locationName = from.locationName
        lon = from.lon ?? 0
        regionName = from.regionName
  }

    static var all: Location = {
        let all = Location()
        all.countryName = "(\(Localized.allCountries()))"
        all.locationName = "(\(Localized.allLocations()))"
        all.regionName = "(\(Localized.allRegions()))"
        return all
    }()

    override var description: String {
        if !countryName.isEmpty
           && !locationName.isEmpty
           && countryName != locationName {
            return Localized.locationDescription(locationName, countryName)
        }
        return locationName.isEmpty ? countryName : locationName
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Location else { return false }
        guard !isSameObject(as: other) else { return true }

        return countryId == other.countryId &&
               countryName == other.countryName &&
               featuredImg == other.featuredImg &&
               id == other.id &&
               lat == other.lat &&
               locationName == other.locationName &&
               lon == other.lon &&
               regionName == other.regionName
    }
}

extension Location: PlaceInfo {

    var placeCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat,
            longitude: lon
        )
    }

    var placeCountry: String {
        return countryName
    }

    var placeId: Int {
        return id
    }

    var placeImage: String {
        return featuredImg ?? ""
    }

    var placeLocation: Location? {
        return self
    }

    var placeIsMappable: Bool {
        return id != 0
    }

    var placeRegion: String {
        return regionName
    }

    var placeTitle: String {
        return locationName
    }

    var placeSubtitle: String {
        return isCountry ? "" : countryName
    }

    var placeIsCountry: Bool {
        return isCountry
    }
}

extension Location {

    var imageUrl: URL? {
        guard let uuid = featuredImg, !uuid.isEmpty else { return nil }
        let target = MTP.picture(uuid: uuid, size: .any)
        return target.requestUrl
    }

    var isCountry: Bool {
        return adminLevel == .country
    }

    var adminLevel: AdminLevel {
        if countryId == id {
            return .country
        }
        return .location
    }
}
