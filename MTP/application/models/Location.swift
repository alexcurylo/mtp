// @copyright Trollwerks Inc.

import CoreLocation

struct Location: Codable {

    let active: String
    let adminLevel: Int
    let airports: String?
    let countryId: Int
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

extension Location: CustomStringConvertible {

    public var description: String {
        return "\(countryName) (\(countryId))"
    }
}

extension Location: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < Location: \(description):
        active: \(active)
        admin_level: \(adminLevel)
        airports: \(String(describing: airports))
        countryId: \(countryId)
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
        /Location >
        """
    }
}

extension Location: PlaceInfo {

    var placeCountry: String {
        return countryName
    }

    var placeId: Int {
        return id
    }

    var placeName: String {
        return title
    }

    var placeRegion: String {
        return regionName
    }
}

extension Location {

    // swiftlint:disable:next closure_body_length
    static var loading: Location = {
        Location(
            active: "",
            adminLevel: 0,
            airports: "",
            countryId: 0,
            countryName: Localized.loading(),
            distance: 0.0,
            featuredImg: "",
            id: 0,
            isMtpLocation: 0,
            isUn: 0,
            lat: 0.0,
            locationName: "",
            lon: 0.0,
            rank: 0,
            rankUn: 0,
            regionId: 0,
            regionName: "",
            visitors: 0,
            visitorsUn: 0,
            weather: "",
            weatherhist: "",
            zoom: 0)
    }()

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat ?? 0,
            longitude: lon ?? 0)
    }

    var title: String { return locationName }

    var subtitle: String { return "" }
}
