// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

@objcMembers final class UNCountry: Object, ServiceProvider {

    dynamic var country: String = ""
    dynamic var id: Int = 0
    dynamic var region: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init?(from: LocationJSON) {
        guard from.active == "Y" else { return nil }
        self.init()

        id = from.id
        // country Swaziland, location eSwatini (Swaziland)
        country = from.locationName
        region = from.regionName
    }

    override var description: String {
        return country
    }
}

extension UNCountry: PlaceInfo {

    var placeCoordinate: CLLocationCoordinate2D {
        return .zero
    }

    var placeParent: PlaceInfo? {
        return nil
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

    var placeSubtitle: String {
        return ""
    }

    var placeTitle: String {
        return country
    }
}
