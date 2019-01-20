// @copyright Trollwerks Inc.

import Foundation

struct UncertainValue<T: Codable, U: Codable>: Codable {

    var tValue: T?
    var uValue: U?

    var value: Any? {
        return tValue ?? uValue
    }

    var intValue: Int? {
        switch value {
        case let intValue as Int:
            return intValue
        case let stringValue as String:
            return Int(stringValue)
        default:
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard !container.decodeNil() else { return }
        tValue = try? container.decode(T.self)
        guard tValue == nil else { return }
        uValue = try? container.decode(U.self)
        guard uValue == nil else { return }
        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "expected a \(T.self) or \(U.self)")
        throw DecodingError.typeMismatch(type(of: self), context)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let tValue = tValue {
            try container.encode(tValue)
        } else if let uValue = uValue {
            try container.encode(uValue)
        } else {
            try container.encodeNil()
        }
    }
}

struct Country: Codable {

    let Country: String?
    let CountryId: UncertainValue<Int, String>? // String in children, not in staging
    let GroupCandidateId: Int?
    let Location: String? // not in staging
    let MLHowtoget: String?
    let RegionIDnew: UncertainValue<Int, String> // String on mtp.travel, Int on aws.mtp.travel
    let RegionName: String?
    let Regionold: Int?
    let URL: String?
    let active: String
    let adminLevel: UncertainValue<Int, String> // String in children
    let airports: String?
    let candidateDate: Date?
    // swiftlint:disable:next discouraged_optional_collection
    let children: [Country]?
    let cities: String?
    let countVisitors: Int?
    let countryId: UncertainValue<Int, String> // String in children, nil in locationSearch
    let countryName: String? // nil in locationSearch
    let cv: String?
    let dateUpdated: Date
    let distance: UncertainValue<Int, String> // Int in new account, nil in old
    let distanceold: String?
    let id: UncertainValue<Int, String> // String in children
    let info: String?
    let isMtpLocation: UncertainValue<Int, String> // String in children
    let isUn: UncertainValue<Int, String> // String in children
    let lat: UncertainValue<Double, String> // Double in new account, nil in old
    let latitude: String?
    let locationName: String
    let lon: UncertainValue<Double, String> // Double in new account, nil in old
    let longitude: String?
    let order: String?
    let rank: Int
    let regionId: UncertainValue<Int, String> // String in children, nil in locationSearch
    let regionName: String?  // nil in locationSearch
    let seaports: String?
    let timename: String?
    let typelevel: String?
    let utc: String?
    let visitors: Int
    let weather: String?
    let weatherhist: String?
    let zoom: UncertainValue<Int, String> // Int in new account, nil in old
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
        RegionIDnew: \(String(describing: RegionIDnew))
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
