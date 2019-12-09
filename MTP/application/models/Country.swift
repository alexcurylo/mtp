// @copyright Trollwerks Inc.

import RealmSwift

/// Country info received from MTP endpoints
struct CountryJSON: Codable {

    private let adminLevel: Int
    fileprivate let countryId: Int
    fileprivate let countryName: String
    fileprivate let hasChildren: Bool
    private let isMtpLocation: Int
}

extension CountryJSON: CustomStringConvertible {

    var description: String {
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

/// Realm representation of a country
@objcMembers final class Country: Object, ServiceProvider {

    /// countryId
    dynamic var countryId: Int = 0
    /// hasChildren
    dynamic var hasChildren: Bool = false
    /// UN country containing place
    dynamic var placeCountry: String = ""

    /// :nodoc:
    override static func primaryKey() -> String? {
        return "countryId"
    }

    /// Constructor from MTP endpoint data
    convenience init(from: CountryJSON) {
        self.init()

        countryId = from.countryId
        hasChildren = from.hasChildren
        placeCountry = from.countryName
    }

    /// Placeholder for all countries
    static var all: Country = {
        let all = Country()
        all.placeCountry = "(\(L.allCountries()))"
        return all
    }()

    override var description: String {
        return placeCountry
    }

    /// children
    var children: [Location] {
        let filter = "countryId = \(countryId) AND countryId != id"
        return data.get(locations: filter)
    }

    /// Equality operator
    /// - Parameter object: Other object
    /// - Returns: equality
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Country else { return false }
        guard !isSameObject(as: other) else { return true }

        return countryId == other.countryId &&
               hasChildren == other.hasChildren &&
               placeCountry == other.placeCountry
    }
}
