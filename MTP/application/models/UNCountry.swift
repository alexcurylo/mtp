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

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "placeId"
    }

    /// Constructor from MTP endpoint data
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

    /// Coordinate for plotting on map
    var placeCoordinate: CLLocationCoordinate2D {
        return .zero
    }

    /// Country's MTP ID
    var placeCountryId: Int {
        return placeId
    }

    /// UUID of main image to display for place
    var placeImageUrl: URL? {
        return placeImage.mtpImageUrl
    }

    /// Title to display to user
    var placeTitle: String {
        return placeCountry
    }

    /// for non-MTP locations, page to load in More Info screen
    var placeWebUrl: URL? {
        let link = "https://mtp.travel/locations/\(placeId)"
        return URL(string: link)
    }
}
