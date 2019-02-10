// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift

struct WHSJSON: Codable {

    let active: String
    let id: Int
    let lat: Double
    let location: PlaceLocation? // nil in 1154?
    let locationId: Int? // nil in 1159?
    let long: Double
    let parentId: Int?
    let rank: Int
    let title: String
    let unescoId: Int
    let visitors: Int
}

extension WHSJSON: CustomStringConvertible {

    public var description: String {
        return "\(String(describing: title)) (\(String(describing: unescoId)))"
    }
}

extension WHSJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < WHSJSON: \(description):
        active: \(active)
        id: \(id)
        lat: \(lat)
        location: \(String(describing: location))
        locationId: \(String(describing: locationId))
        long: \(long)
        parentId: \(String(describing: parentId))
        rank: \(rank)
        title: \(title)
        unescoId: \(unescoId)
        visitors: \(visitors)
        /WHSJSON >
        """
    }
}

@objcMembers final class WHS: Object {

    dynamic var countryName: String = ""
    dynamic var id: Int = 0
    dynamic var lat: Double = 0
    dynamic var long: Double = 0
    dynamic var regionName: String = ""
    dynamic var title: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init?(from: WHSJSON) {
        guard from.active == "Y" else { return nil }
        self.init()

        countryName = from.location?.countryName ?? Localized.unknown()
        id = from.id
        lat = from.lat
        long = from.long
        regionName = from.location?.regionName ?? Localized.unknown()
        title = from.title
    }

    override var description: String {
        return title
    }
}

extension WHS: PlaceInfo {

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

extension WHS {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: lat,
            longitude: long
        )
    }

    var subtitle: String { return "" }
}