// @copyright Trollwerks Inc.

import RealmSwift

struct CountryJSON: Codable {

    let adminLevel: Int
    let countryId: Int
    let countryName: String
    let hasChildren: Bool
    let isMtpLocation: Int
}

extension CountryJSON: CustomStringConvertible {

    public var description: String {
        return countryName
    }
}

extension CountryJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < CountryJSON: \(description):
        admin_level: \(adminLevel)
        countryId: \(countryId)
        countryName: \(countryName)
        hasChildren: \(hasChildren)
        is_mtp_location: \(isMtpLocation)
        /CountryJSON >
        """
    }
}

@objcMembers final class Country: Object, ServiceProvider {

    dynamic var countryId: Int = 0
    dynamic var hasChildren: Bool = false
    dynamic var placeCountry: String = ""

    override static func primaryKey() -> String? {
        return "countryId"
    }

    convenience init(from: CountryJSON) {
        self.init()

        countryId = from.countryId
        hasChildren = from.hasChildren
        placeCountry = from.countryName
    }

    static var all: Country = {
        let all = Country()
        all.placeCountry = "(\(L.allCountries()))"
        return all
    }()

    override var description: String {
        return placeCountry
    }

    var children: [Location] {
        let filter = "countryId = \(countryId) AND countryId != id"
        return data.get(locations: filter)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Country else { return false }
        guard !isSameObject(as: other) else { return true }

        return countryId == other.countryId &&
               hasChildren == other.hasChildren &&
               placeCountry == other.placeCountry
    }
}
