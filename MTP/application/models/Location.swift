// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

enum AdminLevel: Int {
    case unknown = 0
    case country = 2
    case location = 4
}

struct LocationJSON: Codable, Equatable {

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

@objcMembers final class Location: Object, Mappable, ServiceProvider {

    dynamic var map: MapInfo?

    dynamic var adminLevel: AdminLevel = .unknown
    dynamic var airports: String = ""
    dynamic var countryId: Int = 0
    dynamic var placeCountry: String = ""
    dynamic var placeId: Int = 0
    dynamic var placeRegion: String = ""
    dynamic var placeTitle: String = ""
    dynamic var rank: Int = 0
    dynamic var rankUn: Int = 0
    dynamic var weatherhist: String = ""

    override static func primaryKey() -> String? {
        return "placeId"
    }

    convenience init?(from: LocationJSON) {
        guard from.active == "Y",
              let country = from.countryId,
              country > 0 else { return nil }
        self.init()

        adminLevel = AdminLevel(rawValue: from.adminLevel) ?? .unknown
        let subtitle = isCountry ? "" : from.countryName
        let website = "https://mtp.travel/locations/\(from.id)"
        map = MapInfo(checklist: .locations,
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

    var placeCountryId: Int {
        return countryId
    }

    var placeLocation: Location? {
        return self
    }

    var placeIsMappable: Bool {
        return placeId != 0
    }

    var placeSubtitle: String {
        return map?.subtitle ?? ""
    }

    enum Inexpandibles: Int {
        case netherlandsMainland = 301
        case portugalMainland = 305
        case turkishThrace = 325
    }

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

    var flagUrl: URL? {
        let link = "https://mtp.travel/flags/\(countryId)"
        return URL(string: link)
    }

    var isCountry: Bool {
        return adminLevel == .country
    }

    var latitude: CLLocationDegrees {
        return map?.latitude ?? 0
    }

    var longitude: CLLocationDegrees {
        return map?.longitude ?? 0
    }
}
