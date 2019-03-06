// @copyright Trollwerks Inc.

import Foundation

struct RegistrationInfo: Codable {

    struct CountryInfo: Codable {
        let admin_level: Int
        let country_id: Int
        let country_name: String
        let has_children: Bool
        let is_mtp_location: Int

        var isValid: Bool {
            return country_id > 0 &&
                   !country_name.isEmpty
        }

        init(country: Country) {
            admin_level = AdminLevel.country.rawValue
            country_id = country.countryId
            country_name = country.countryName
            has_children = country.hasChildren
            is_mtp_location = has_children ? 0 : 1
        }
    }

    struct LocationInfo: Codable {
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

        init(location: Location) {
            admin_level = AdminLevel.location.rawValue
            country_id = location.countryId
            country_name = location.countryName
            id = location.id
            is_mtp_location = 1
            location_name = location.locationName
        }
    }

    let birthday: Date
    let country: CountryInfo
    let country_id: Int
    let email: String
    let first_name: String
    let gender: String
    let last_name: String
    let location: LocationInfo
    let location_id: Int
    let password: String
    let passwordConfirmation: String

    var isValid: Bool {
        return country.isValid &&
               !email.isEmpty &&
               !first_name.isEmpty &&
               !gender.isEmpty &&
               !last_name.isEmpty &&
               (!country.has_children || location.isValid) &&
               !password.isEmpty &&
               password == passwordConfirmation
    }

    init(birthday: Date,
         country: Country,
         firstName: String,
         email: String,
         gender: Gender,
         lastName: String,
         location: Location,
         password: String,
         passwordConfirmation: String) {
        self.birthday = birthday
        self.country = CountryInfo(country: country)
        country_id = country.countryId
        self.email = email
        first_name = firstName
        self.gender = gender.rawValue
        last_name = lastName
        self.location = LocationInfo(location: location)
        location_id = location.id
        self.password = password
        self.passwordConfirmation = passwordConfirmation
    }
}
