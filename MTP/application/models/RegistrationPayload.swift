// @copyright Trollwerks Inc.

import Foundation

struct RegistrationPayload: Codable, Hashable {

    let birthday: String?
    let country: CountryPayload
    let country_id: Int
    let email: String
    let first_name: String
    let gender: String
    let last_name: String
    let location: LocationPayload
    let location_id: Int
    let password: String
    let passwordConfirmation: String

    var isValid: Bool {
        return country.isValid &&
               country_id > 0 &&
               !email.isEmpty &&
               !first_name.isEmpty &&
               !last_name.isEmpty &&
               location.isValid &&
               location_id > 0 &&
               //!birthday.isEmpty &&
               //!gender.isEmpty &&
               !password.isEmpty &&
               password == passwordConfirmation
    }

    init(birthday: String?,
         country: Country,
         firstName: String,
         email: String,
         gender: String,
         lastName: String,
         location: Location,
         password: String,
         passwordConfirmation: String) {
        self.birthday = birthday
        self.country = CountryPayload(country: country)
        country_id = country.countryId
        self.email = email
        first_name = firstName
        self.gender = gender
        last_name = lastName
        self.location = LocationPayload(location: location)
        location_id = location.placeId
        self.password = password
        self.passwordConfirmation = passwordConfirmation
    }

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

        country = CountryPayload(country: Country())
        country_id = 0
        location = LocationPayload(location: Location())
        location_id = 0
        password = ""
        passwordConfirmation = ""
    }
}

struct CountryPayload: Codable, Hashable {

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

struct LocationPayload: Codable, Hashable {

    let admin_level: Int
    let country_id: Int
    let country_name: String
    let id: Int
    let is_mtp_location: Int
    let location_name: String

    var isValid: Bool {
        return country_id > 0 &&
               !country_name.isEmpty &&
               id > 0 &&
               !location_name.isEmpty
    }

    init() {
        admin_level = 0
        country_id = 0
        country_name = ""
        id = 0
        is_mtp_location = 0
        location_name = ""
    }

    init(country: Country) {
        admin_level = AdminLevel.country.rawValue
        country_id = country.countryId
        country_name = country.placeCountry
        id = country.countryId
        is_mtp_location = country.hasChildren ? 0 : 1
        location_name = country.placeCountry
    }

    init(location: Location) {
        admin_level = location.adminLevel.rawValue
        country_id = location.countryId
        country_name = location.placeCountry
        id = location.placeId
        is_mtp_location = 1
        location_name = location.placeTitle
    }
}
