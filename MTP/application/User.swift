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
    let role: Bool
    let score: String
    let scoreBeaches: String
    let scoreDivesites: String
    let scoreGolfcourses: String
    let scoreLocations: String
    let scoreRestaurants: String
    let scoreUncountries: String
    let scoreWhss: String
    let status: String
    let token: String
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
            token: \(token)
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

struct Country: Codable {

    let Country: String?
    let CountryId: Int?
    let GroupCandidateId: Int?
    let Location: String
    let MLHowtoget: String?
    let RegionIDnew: String
    let RegionName: String?
    let Regionold: Int?
    let URL: String?
    let countryName: String
    let active: String
    let adminLevel: Int
    let airports: String?
    let candidateDate: Date?
    let cities: String?
    let countryId: Int
    let countVisitors: Int
    let cv: String?
    let info: String?
    let isMtpLocation: Int
    let lat: String?
    let latitude: String?
    let lon: String?
    let longitude: String?
    let dateUpdated: Date
    let distance: String?
    let distanceold: String?
    let id: Int
    let isUn: Int
    let locationName: String
    let order: String?
    let rank: String
    let regionId: Int
    let regionName: String
    let seaports: String?
    let timename: String?
    let typelevel: String?
    let utc: String?
    let visitors: String
    let weather: String?
    let weatherhist: String?
    let zoom: String?
}

extension Country: CustomStringConvertible {

    public var description: String {
        return "\(countryName) (\(countryId)))"
    }
}

extension Country: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < Country: \(description):
            Country: \(String(describing: Country))
            CountryId: \(String(describing: CountryId))
            GroupCandidate_id: \(String(describing: GroupCandidateId))
            Location: \(Location)
            ML_howtoget: \(String(describing: MLHowtoget))
            RegionIDnew: \(RegionIDnew)
            RegionName: \(String(describing: RegionName))
            Regionold: \(String(describing: Regionold))
            URL: \(String(describing: URL))
            active: \(active)
            admin_level: \(adminLevel)
            airports: \(String(describing: airports))
            candidate_date: \(String(describing: candidateDate))
            cities: \(String(describing: cities))
            countryId: \(countryId)
            countryName: \(countryName)
            cv: \(String(describing: cv))
            count_visitors: \(countVisitors)
            dateUpdated: \(dateUpdated)
            distance: \(String(describing: distance))
            distanceold: \(String(describing: distanceold))
            is_mtp_location: \(isMtpLocation)
            id: \(id)
            info: \(String(describing: info))
            is_un: \(isUn)
            lat: \(String(describing: lat))
            latitude: \(String(describing: latitude))
            lon: \(String(describing: lon))
            longitude: \(String(describing: longitude))
            location_name: \(locationName)
            order: \(String(describing: order))
            rank: \(rank)
            region_id: \(regionId)
            region_name: \(regionName)
            seaports: \(String(describing: seaports))
            timename: \(String(describing: timename))
            typelevel: \(String(describing: typelevel))
            utc: \(String(describing: utc))
            visitors: \(visitors)
            weather: \(String(describing: utc))
            weatherhist: \(String(describing: utc))
            zoom: \(String(describing: utc))
        /Country >
        """
    }
}
