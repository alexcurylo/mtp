// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

@objcMembers final class UNCountry: Object, ServiceProvider {

    dynamic var placeCountry: String = ""
    dynamic var placeId: Int = 0
    dynamic var placeImage: String = ""
    dynamic var placeLocation: Location?
    dynamic var placeVisitors: Int = 0
    dynamic var placeRegion: String = ""

    override static func primaryKey() -> String? {
        return "placeId"
    }

    convenience init?(from: LocationJSON) {
        guard from.active == "Y" else {
            return nil
        }
        self.init()

        placeId = from.id
        // all match except country Swaziland, location eSwatini (Swaziland)
        placeCountry = from.countryName
        placeVisitors = from.visitors
        placeRegion = from.regionName
    }
}

extension UNCountry: PlaceInfo {

    var placeIsMappable: Bool {
        return false
    }

    var placeCoordinate: CLLocationCoordinate2D {
        return .zero
    }

    var placeCountryId: Int {
        return placeId
    }

    var placeImageUrl: URL? {
        return placeImage.mtpImageUrl
    }

    var placeTitle: String {
        return placeCountry
    }

    var placeWebUrl: URL? {
        let link = "https://mtp.travel/locations/\(placeId)"
        return URL(string: link)
    }
}
