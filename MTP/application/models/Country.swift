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
    dynamic var countryName: String = ""
    dynamic var hasChildren: Bool = false

    override static func primaryKey() -> String? {
        return "countryId"
    }

    convenience init(from: CountryJSON) {
        self.init()

        countryId = from.countryId
        countryName = from.countryName
        hasChildren = from.hasChildren
    }

    static var all: Country = {
        let all = Country()
        all.countryName = "(\(Localized.allCountries()))"
        return all
    }()

    override var description: String {
        return countryName
    }

    var children: [Location] {
        let filter = "countryId = \(countryId) AND countryId != id"
        return data.get(locations: filter)
    }
}
