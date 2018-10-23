// @copyright Trollwerks Inc.

import UIKit

struct User: Codable {

    let airport: String?
    let bio: String
    let birthday: Date
    let country: Country
    let countryId: String
    let createdAt: Date
    let email: String
    let facebookEmail: String?
    let facebookId: String?
    let facebookUserToken: String?
    let favoritePlaces: [FavoritePlace]
    let firstName: String
    let fullName: String
    let gender: String
    let id: Int
    let lastLogIn: String?
    let lastName: String
    let location: Country
    let links: [Link]
    let locationId: String
    let picture: String
    let role: Int
    let score: String
    let scoreBeaches: String
    let scoreDivesites: String
    let scoreGolfcourses: String
    let scoreLocations: String
    let scoreRestaurants: String
    let scoreUncountries: String
    let scoreWhss: String
    let status: String
    let token: String? // found only in login response
    let updatedAt: Date
    let username: String
}

extension User: CustomStringConvertible {

    public var description: String {
        return "\(username) (\(id))"
    }
}

extension User: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < User: \(description):
            airport: \(String(describing: airport))
            bio: \(bio)
            birthday: \(birthday)
            country: \(country.debugDescription)
            country_id: \(countryId)
            created_at: \(createdAt)
            email: \(email)
            facebook_email: \(String(describing: facebookEmail))
            facebook_id: \(String(describing: facebookId))
            facebook_user_token: \(String(describing: facebookUserToken))
            favorite_places: \(favoritePlaces.debugDescription)
            first_name: \(firstName)
            full_name: \(fullName)
            gender: \(gender)
            id: \(id)
            last_log_in: \(String(describing: lastLogIn))
            last_name: \(lastName)
            location: \(location.debugDescription)
            links: \(links.debugDescription)
            location_id: \(locationId)
            picture: \(picture)
            role: \(role)
            score: \(score)
            score_beaches: \(scoreBeaches)
            score_divesites: \(scoreDivesites)
            score_golfcourses: \(scoreGolfcourses)
            score_locations: \(scoreLocations)
            score_restaurants: \(scoreRestaurants)
            score_uncountries: \(scoreUncountries)
            score_whss: \(scoreWhss)
            status: \(status)
            token: \(String(describing: token))
            updated_at: \(updatedAt)
            username: \(username)
        /User >
        """
    }
}

struct FavoritePlace: Codable {

    let id: String
    let type: String
}

extension FavoritePlace: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return debugDescription
    }

    public var debugDescription: String {
        return "< Favorite Place: id \(id) type \(type)>"
    }
}

struct Link: Codable {

    let text: String
    let url: String
}

extension Link: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return debugDescription
    }

    public var debugDescription: String {
        return "< Link: text \(text) url \(url)>"
    }
}

extension User {

    var visited: Int {
        return Int(scoreLocations) ?? 0
    }

    var remaining: Int {
        return Country.count - visited
    }
}

enum Gender: Int, Codable {
    case all
    case female
    case male
}

extension Gender: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        switch self {
        case .all: return ""
        case .female: return Localized.female()
        case .male: return Localized.male()
        }
    }

    public var debugDescription: String {
        return String(rawValue)
    }
}

struct UserFilter: Codable, Equatable {

    var countryId: Int?
    var provinceId: Int?
    var gender: Gender = .all
    var ageMin: Int?
    var ageMax: Int?
    var facebook: Bool = false
}

extension UserFilter: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return debugDescription
    }

    public var debugDescription: String {
        let components: [String] = [
            locationDescription,
            gender.description,
            ageDescription,
            facebookDescription
        ].compactMap { $0 }.filter { !$0.isEmpty }
        return components.joined(separator: Localized.join())
    }

    private var locationDescription: String {
        log.todo("UserFilter.location")
        return Localized.allLocations()
    }

    private var ageDescription: String? {
        log.todo("UserFilter.ageDescription")
        return nil
    }

    private var facebookDescription: String? {
        return facebook ? Localized.facebookFriends() : nil
    }
}
