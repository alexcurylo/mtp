// @copyright Trollwerks Inc.

import Foundation

struct Location: Codable {
    let Country: String? // not in staging
    let CountryId: Int? // not in staging
    let Location: String? // not in staging
    let RegionIDnew: String? // not in staging
    let RegionName: String? // not in staging
    let active: String? // not in staging
    let adminLevel: Int? // not in staging
    let airports: String?
    let countryId: Int
    let countryName: String
    let countVisitors: Int? // not in staging
    let dateUpdated: Date? // not in staging
    let distance: UncertainValue<Double, String> // Double in staging, String in production
    let featuredImg: String?
    let id: Int
    let isMtpLocation: Int
    let isUn: Int
    let lat: UncertainValue<Double, String> // Double in staging, String in production
    let latitude: String?
    let locationName: String
    let lon: UncertainValue<Double, String> // Double in staging, String in production
    let longitude: String?
    let rank: Int
    let rankUn: Int
    let regionId: Int
    let regionName: String
    let visitors: Int
    let visitorsUn: Int
    let weather: String?
    let weatherhist: String?
    let zoom: UncertainValue<Int, String> // Int in staging, String in production
}

extension Location: CustomStringConvertible {

    public var description: String {
        return "\(String(describing: countryName)) (\(String(describing: countryId)))"
    }
}

extension Location: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < Location: \(description):
        Country: \(String(describing: Country))
        CountryId: \(String(describing: CountryId))
        Location: \(String(describing: Location))
        RegionIDnew: \(String(describing: RegionIDnew))
        RegionName: \(String(describing: RegionName))
        active: \(String(describing: active))
        admin_level: \(String(describing: adminLevel))
        airports: \(String(describing: airports))
        countryId: \(String(describing: countryId))
        countryName: \(String(describing: countryName))
        count_visitors: \(String(describing: countVisitors))
        dateUpdated: \(String(describing: dateUpdated))
        distance: \(String(describing: distance))
        is_mtp_location: \(isMtpLocation)
        id: \(id)
        is_un: \(isUn)
        lat: \(String(describing: lat))
        latitude: \(String(describing: latitude))
        lon: \(String(describing: lon))
        longitude: \(String(describing: longitude))
        location_name: \(locationName)
        rank: \(rank)
        region_id: \(String(describing: regionId))
        region_name: \(String(describing: regionName))
        visitors: \(visitors)
        /Location >
        """
    }
}

extension Location {

    static var count: Int {
        return gestalt.locations.count
    }
}
