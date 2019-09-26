// @copyright Trollwerks Inc.

import Foundation

/// Sent to the sign up endpoint
struct RegistrationPayload: Codable, Hashable {

    /// YYYY-MM-DD
    let birthday: String?
    /// Country of residence
    fileprivate let country: CountryPayload?
    /// ID of country of residence
    let country_id: Int
    /// Email
    let email: String
    /// First Name
    let first_name: String
    /// M|F|U
    let gender: String
    /// Last name
    let last_name: String
    /// MTP location of residence
    fileprivate let location: LocationPayload?
    /// ID of location of residence
    let location_id: Int
    /// Password
    let password: String
    /// Password check
    let passwordConfirmation: String

    /// Check fields required by endpoint
    var isValid: Bool {
        return !email.isEmpty &&
               !first_name.isEmpty &&
               !last_name.isEmpty &&
               //country.isValid &&
               //country_id > 0 &&
               //location.isValid &&
               //location_id > 0 &&
               //!birthday.isEmpty &&
               //!gender.isEmpty &&
               !password.isEmpty &&
               password == passwordConfirmation
    }

    /// Initialize with data
    ///
    /// - Parameters:
    ///   - birthday: YYYY-MM-DD
    ///   - country: Country of residence
    ///   - firstName: First Name
    ///   - email: Email
    ///   - gender: M|F|U
    ///   - lastName: Last name
    ///   - location: MTP location of residence
    ///   - password: Password
    ///   - passwordConfirmation: Password check
    init(birthday: String?,
         country: Country?,
         firstName: String,
         email: String,
         gender: String,
         lastName: String,
         location: Location?,
         password: String,
         passwordConfirmation: String) {
        self.birthday = birthday
        if let country = country {
            self.country = CountryPayload(country: country)
            country_id = country.countryId
        } else {
            self.country = nil
            country_id = 0
        }
        self.email = email
        first_name = firstName
        self.gender = gender
        last_name = lastName
        if let location = location {
            self.location = LocationPayload(location: location)
            location_id = location.placeId
        } else {
            self.location = nil
            location_id = 0
        }
        self.password = password
        self.passwordConfirmation = passwordConfirmation
    }

    /// Initialize with Facebook data
    ///
    /// - Parameter response: Provided by Facebook SDK
    init(facebook response: [String: Any]) {
        if let dateString = response["birthday"] as? String,
           let date = DateFormatter.fbDay.date(from: dateString) {
            birthday = DateFormatter.mtpDay.string(from: date)
        } else {
            birthday = nil
        }
        email = response["email"] as? String ?? ""
        first_name = response["first_name"] as? String ?? ""
        switch response["gender"] as? String {
        case "female": gender = "F"
        case "male": gender = "M"
        default: gender = "U"
        }
        last_name = response["last_name"] as? String ?? ""

        country = nil
        country_id = 0
        location = nil
        location_id = 0
        password = ""
        passwordConfirmation = ""
    }
}

private struct CountryPayload: Codable, Hashable {

    let admin_level: Int
    let country_id: Int
    let country_name: String
    let has_children: Bool
    let is_mtp_location: Int

    var isValid: Bool {
        return country_id > 0 && !country_name.isEmpty
    }

    init(country: Country) {
        admin_level = AdminLevel.country.rawValue
        country_id = country.countryId
        country_name = country.placeCountry
        has_children = country.hasChildren
        is_mtp_location = has_children ? 0 : 1
    }
}

/// Location information to send to API
struct LocationPayload: Codable, Hashable {

    fileprivate let admin_level: Int
    fileprivate let country_id: Int
    fileprivate let country_name: String
    /// MTP location ID
    let id: Int
    fileprivate let is_mtp_location: Int
    /// MTP location name
    let location_name: String

    /// Is payload valid?
    var isValid: Bool {
        return country_id > 0 &&
               !country_name.isEmpty &&
               id > 0 &&
               !location_name.isEmpty
    }

    /// :nodoc:
    init() {
        admin_level = 0
        country_id = 0
        country_name = ""
        id = 0
        is_mtp_location = 0
        location_name = ""
    }

    /// :nodoc:
    init(info: LocationPayloadInfo) {
        admin_level = info.admin_level
        country_id = info.country_id
        country_name = info.country_name
        id = info.id
        is_mtp_location = info.id
        location_name = info.location_name
    }

    /// :nodoc:
    init(country: Country) {
        admin_level = AdminLevel.country.rawValue
        country_id = country.countryId
        country_name = country.placeCountry
        id = country.countryId
        is_mtp_location = country.hasChildren ? 0 : 1
        location_name = country.placeCountry
    }

    /// :nodoc:
    init(location: Location) {
        admin_level = location.adminLevel
        country_id = location.countryId
        country_name = location.placeCountry
        id = location.placeId
        is_mtp_location = 1
        location_name = location.placeTitle
    }
}

/// Payload stored in queue
final class LocationPayloadInfo: NSObject, NSCoding {

    fileprivate let admin_level: Int
    fileprivate let country_id: Int
    fileprivate let country_name: String
    fileprivate let id: Int
    fileprivate let is_mtp_location: Int
    fileprivate let location_name: String

    private static let keys = (admin_level: "admin_level",
                               country_id: "country_id",
                               country_name: "country_name",
                               id: "id",
                               is_mtp_location: "is_mtp_location",
                               location_name: "location_name")

    /// :nodoc:
    init(admin_level: Int,
         country_id: Int,
         country_name: String,
         id: Int,
         is_mtp_location: Int,
         location_name: String) {
        self.admin_level = admin_level
        self.country_id = country_id
        self.country_name = country_name
        self.id = id
        self.is_mtp_location = is_mtp_location
        self.location_name = location_name
    }

    /// :nodoc:
    init(payload: LocationPayload) {
        admin_level = payload.admin_level
        country_id = payload.country_id
        country_name = payload.country_name
        id = payload.id
        is_mtp_location = payload.is_mtp_location
        location_name = payload.location_name
    }

    /// :nodoc:
    required convenience init?(coder decoder: NSCoder) {
        let admin_level = decoder.decodeInteger(forKey: LocationPayloadInfo.keys.admin_level)
        let country_id = decoder.decodeInteger(forKey: LocationPayloadInfo.keys.country_id)
        let id = decoder.decodeInteger(forKey: LocationPayloadInfo.keys.id)
        let is_mtp_location = decoder.decodeInteger(forKey: LocationPayloadInfo.keys.is_mtp_location)
        guard let country_name = decoder.decodeObject(forKey: LocationPayloadInfo.keys.country_name),
            let location_name = decoder.decodeObject(forKey: LocationPayloadInfo.keys.location_name) else {
            return nil
        }
        self.init(
            admin_level: admin_level,
            country_id: country_id,
            // swiftlint:disable:next force_cast
            country_name: country_name as! String,
            id: id,
            is_mtp_location: is_mtp_location,
            // swiftlint:disable:next force_cast
            location_name: location_name as! String
        )
    }

    /// :nodoc:
    func encode(with coder: NSCoder) {
        coder.encode(admin_level, forKey: LocationPayloadInfo.keys.admin_level)
        coder.encode(country_id, forKey: LocationPayloadInfo.keys.country_id)
        coder.encode(country_name, forKey: LocationPayloadInfo.keys.country_name)
        coder.encode(id, forKey: LocationPayloadInfo.keys.id)
        coder.encode(is_mtp_location, forKey: LocationPayloadInfo.keys.is_mtp_location)
        coder.encode(location_name, forKey: LocationPayloadInfo.keys.location_name)
    }
}
