// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

@objcMembers final class UNCountry: Object, ServiceProvider {

    dynamic var country: String = ""
    dynamic var id: Int = 0
    dynamic var placeImage: String = ""
    dynamic var placeLocation: Location?
    dynamic var placeVisitors: Int = 0
    dynamic var region: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init?(from: LocationJSON) {
        guard from.active == "Y" else {
            return nil
        }
        self.init()

        id = from.id
        // all match except country Swaziland, location eSwatini (Swaziland)
        country = from.countryName
        placeVisitors = from.visitors
        region = from.regionName
    }
}

extension UNCountry: PlaceInfo {

    var placeIsMappable: Bool {
        return false
    }

    var placeCoordinate: CLLocationCoordinate2D {
        return .zero
    }

    var placeCountry: String {
        return country
    }

    var placeId: Int {
        return id
    }

    var placeRegion: String {
        return region
    }

    var placeTitle: String {
        return country
    }
}
