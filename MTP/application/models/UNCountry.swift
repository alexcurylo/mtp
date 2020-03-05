// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

/// Realm representation of a UNCountry place
@objcMembers final class UNCountry: Object, ServiceProvider {

    /// UN country containing place
    dynamic var placeCountry: String = ""
    /// Place's MTP ID
    dynamic var placeId: Int = 0
    /// UUID of main image to display for place
    dynamic var placeImage: String = ""
    /// MTP location containing place
    dynamic var placeLocation: Location?
    /// Number of MTP visitors
    dynamic var placeVisitors: Int = 0
    /// Region containing the country
    dynamic var placeRegion: String = ""

    /// :nodoc:
    override static func primaryKey() -> String? {
        "placeId"
    }
}

extension UNCountry: PlaceInfo {

    /// Coordinate for plotting on map
    var placeCoordinate: CLLocationCoordinate2D {
        .zero
    }

    /// Country's MTP ID
    var placeCountryId: Int {
        placeId
    }

    /// UUID of main image to display for place
    var placeImageUrl: URL? {
        placeImage.mtpImageUrl
    }

    /// Title to display to user
    var placeTitle: String {
        placeCountry
    }

    /// for non-MTP locations, page to load in More Info screen
    var placeWebUrl: URL? {
        let link = "https://mtp.travel/locations/\(placeId)"
        return URL(string: link)
    }
}
