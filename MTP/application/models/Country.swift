// @copyright Trollwerks Inc.

import CoreLocation

struct Country: Codable {

    //let Country: String?
    let CountryId: UncertainValue<Int, String>? // String in children, not in staging
    let GroupCandidateId: Int?
    let Location: String? // not in staging
    let MLHowtoget: String?
    let RegionIDnew: UncertainValue<Int, String>? // String on in production, Int? in staging
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
    let dateUpdated: Date? // not in staging
    let distance: UncertainValue<Double, String> // Double in staging, String in production
    let distanceold: String?
    let id: UncertainValue<Int, String> // String in children
    let info: String?
    let isMtpLocation: UncertainValue<Int, String> // String in children
    let isUn: UncertainValue<Int, String> // String in children
    let lat: UncertainValue<Double, String> // Double in staging, nil in old
    let latitude: String?
    let locationName: String
    let lon: UncertainValue<Double, String> // Double in staging, nil in old
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
    let zoom: UncertainValue<Int, String> // Int in staging, nil in old
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
        CountryId: \(String(describing: CountryId))
        GroupCandidate_id: \(String(describing: GroupCandidateId))
        Location: \(String(describing: Location))
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
        dateUpdated: \(String(describing: dateUpdated))
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

extension Country: PlaceInfo {

    var placeCountry: String {
        return countryName ?? Localized.unknown()
    }

    var placeId: Int {
        return id.intValue ?? 0
    }

    var placeName: String {
        return title
    }

    var placeRegion: String {
        return regionName ?? Localized.unknown()
    }
}

extension Country {

    // swiftlint:disable:next closure_body_length
    static var loading: Country = {
        Country(
            CountryId: nil,
            GroupCandidateId: nil,
            Location: nil,
            MLHowtoget: nil,
            RegionIDnew: nil,
            RegionName: nil,
            Regionold: nil,
            URL: nil,
            active: "",
            adminLevel: UncertainValue<Int, String>(with: 0),
            airports: nil,
            candidateDate: nil,
            children: nil,
            cities: nil,
            countVisitors: nil,
            countryId: UncertainValue<Int, String>(with: 0),
            countryName: Localized.loading(),
            cv: nil,
            dateUpdated: nil,
            distance: UncertainValue<Double, String>(with: 0),
            distanceold: nil,
            id: UncertainValue<Int, String>(with: 0),
            info: nil,
            isMtpLocation: UncertainValue<Int, String>(with: 0),
            isUn: UncertainValue<Int, String>(with: 0),
            lat: UncertainValue<Double, String>(with: 0),
            latitude: nil,
            locationName: "",
            lon: UncertainValue<Double, String>(with: 0),
            longitude: nil,
            order: nil,
            rank: 0,
            regionId: UncertainValue<Int, String>(with: 0),
            regionName: nil,
            seaports: nil,
            timename: nil,
            typelevel: nil,
            utc: nil,
            visitors: 0,
            weather: nil,
            weatherhist: nil,
            zoom: UncertainValue<Int, String>(with: 0))
    }()

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat.doubleValue ?? 0,
            longitude: lon.doubleValue ?? 0
        )
    }

    var title: String { return locationName }

    var subtitle: String { return "" }
}
