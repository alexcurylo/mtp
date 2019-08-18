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
    /// id
    let id: Int
    fileprivate let is_mtp_location: Int
    fileprivate let location_name: String

    /// Is payload valid?
    var isValid: Bool {
        return country_id > 0 &&
               !country_name.isEmpty &&
               id > 0 &&
               !location_name.isEmpty
    }

    /// Default constructor
    init() {
        admin_level = 0
        country_id = 0
        country_name = ""
        id = 0
        is_mtp_location = 0
        location_name = ""
    }

    /// Initialize with Country
    ///
    /// - Parameter country: Country
    init(country: Country) {
        admin_level = AdminLevel.country.rawValue
        country_id = country.countryId
        country_name = country.placeCountry
        id = country.countryId
        is_mtp_location = country.hasChildren ? 0 : 1
        location_name = country.placeCountry
    }

    /// Initialize with Location
    ///
    /// - Parameter country: Location
    init(location: Location) {
        admin_level = location.adminLevel
        country_id = location.countryId
        country_name = location.placeCountry
        id = location.placeId
        is_mtp_location = 1
        location_name = location.placeTitle
    }
}
