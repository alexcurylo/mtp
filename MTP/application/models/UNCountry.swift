// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

@objcMembers final class UNCountry: Object {

    dynamic var countryName: String = ""
    dynamic var id: Int = 0
    dynamic var lat: Double?
    dynamic var locationName: String = ""
    dynamic var lon: Double?
    dynamic var regionName: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init?(from: LocationJSON) {
        guard from.active == "Y" else { return nil }
        self.init()

        countryName = from.countryName
        id = from.id
        lat = from.lat
        locationName = from.locationName
        lon = from.lon
        regionName = from.regionName
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
            latitude: lat ?? 0,
            longitude: lon ?? 0)
    }

    var title: String { return locationName }

    var subtitle: String { return "" }
}
