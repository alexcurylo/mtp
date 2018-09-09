// @copyright Trollwerks Inc.

import Foundation

public struct UncertainValue<T: Codable, U: Codable>: Codable {

    public var tValue: T?
    public var uValue: U?

    public var value: Any? {
        return tValue ?? uValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        tValue = try? container.decode(T.self)
        guard tValue == nil else { return }
        uValue = try? container.decode(U.self)
        guard uValue == nil else { return }
        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "expected a \(T.self) or \(U.self)")
        throw DecodingError.typeMismatch(type(of: self), context)
    }
}

struct Country: Codable {

    let Country: String?
    let CountryId: UncertainValue<Int, String>? // String in children
    let GroupCandidateId: Int?
    let Location: String
    let MLHowtoget: String?
    let RegionIDnew: String
    let RegionName: String?
    let Regionold: Int?
    let URL: String?
    let countryName: String? // nil in locationSearch
    let active: String
    let adminLevel: UncertainValue<Int, String> // String in children
    let airports: String?
    let candidateDate: Date?
    // swiftlint:disable:next discouraged_optional_collection
    let children: [Country]?
    let cities: String?
    let countryId: UncertainValue<Int, String>? // String in children, nil in locationSearch
    let countVisitors: Int?
    let cv: String?
    let info: String?
    let isMtpLocation: UncertainValue<Int, String> // String in children
    let lat: String?
    let latitude: String?
    let lon: String?
    let longitude: String?
    let dateUpdated: Date
    let distance: String?
    let distanceold: String?
    let id: UncertainValue<Int, String> // String in children
    let isUn: UncertainValue<Int, String> // String in children
    let locationName: String
    let order: String?
    let rank: String
    let regionId: UncertainValue<Int, String>? // String in children, nil in locationSearch
    let regionName: String?  // nil in locationSearch
    let seaports: String?
    let timename: String?
    let typelevel: String?
    let utc: String?
    let visitors: String
    let weather: String?
    let weatherhist: String?
    let zoom: String?
}

extension Country: CustomStringConvertible {

    public var description: String {
        return "\(String(describing: countryName)) (\(String(describing: countryId)))"
    }
}

extension Country: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < Country: \(description):
        Country: \(String(describing: Country))
        CountryId: \(String(describing: CountryId))
        GroupCandidate_id: \(String(describing: GroupCandidateId))
        Location: \(Location)
        ML_howtoget: \(String(describing: MLHowtoget))
        RegionIDnew: \(RegionIDnew)
        RegionName: \(String(describing: RegionName))
        Regionold: \(String(describing: Regionold))
        URL: \(String(describing: URL))
        active: \(active)
        admin_level: \(adminLevel)
        airports: \(String(describing: airports))
        children: \(String(describing: children))
        candidate_date: \(String(describing: candidateDate))
        cities: \(String(describing: cities))
        countryId: \(String(describing: countryId))
        countryName: \(String(describing: countryName))
        cv: \(String(describing: cv))
        count_visitors: \(String(describing: countVisitors))
        dateUpdated: \(dateUpdated)
        distance: \(String(describing: distance))
        distanceold: \(String(describing: distanceold))
        is_mtp_location: \(isMtpLocation)
        id: \(id)
        info: \(String(describing: info))
        is_un: \(isUn)
        lat: \(String(describing: lat))
        latitude: \(String(describing: latitude))
        lon: \(String(describing: lon))
        longitude: \(String(describing: longitude))
        location_name: \(locationName)
        order: \(String(describing: order))
        rank: \(rank)
        region_id: \(String(describing: regionId))
        region_name: \(String(describing: regionName))
        seaports: \(String(describing: seaports))
        timename: \(String(describing: timename))
        typelevel: \(String(describing: typelevel))
        utc: \(String(describing: utc))
        visitors: \(visitors)
        weather: \(String(describing: utc))
        weatherhist: \(String(describing: utc))
        zoom: \(String(describing: utc))
        /Country >
        """
    }
}
