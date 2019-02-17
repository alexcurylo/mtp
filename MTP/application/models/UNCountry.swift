// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

@objcMembers final class UNCountry: Object, ServiceProvider {

    dynamic var countryName: String = ""
    dynamic var id: Int = 0
    dynamic var lat: Double = 0
    dynamic var locationName: String = ""
    dynamic var lon: Double = 0
    dynamic var regionName: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init?(from: LocationJSON) {
        guard from.active == "Y" else { return nil }
        self.init()

        countryName = from.countryName
        id = from.id
        locationName = from.locationName
        regionName = from.regionName
        if let latitude = from.lat,
           let longitude = from.lon {
            lat = latitude
            lon = longitude
        } else {
            log.warning("UNCountry nil coordinates: \(countryName)")
            lat = 0
            lon = 0
        }
    }

    override var description: String {
        if !countryName.isEmpty
            && !locationName.isEmpty
            && countryName != locationName {
            return "\(locationName), \(countryName)"
        }
        return locationName.isEmpty ? countryName : locationName
    }
}

extension UNCountry: PlaceInfo {

    var placeParent: PlaceInfo? {
        return nil
    }

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

extension UNCountry {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat,
            longitude: lon)
    }

    var title: String { return locationName }

    var subtitle: String { return "" }
}
