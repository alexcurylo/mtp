// @copyright Trollwerks Inc.

import Foundation

/// Reply from the user update endpoint
struct UserUpdateReply: Codable {

    /// HTTP result code
    let code: Int
    /// Result message
    let message: String
    /// Updated user
    let user: UserJSON

    /// Whether operation succeeded
    var isSuccess: Bool {
        code == 200
    }
}

/// Sent to the user update endpoint
/// expect everything in UserJSON except country, location structs
struct UserUpdatePayload: Codable, Hashable, UserAvatar {

    /// airport
    var airport: String?
    /// bio
    var bio: String?
    /// birthday
    var birthday: String?
    /// country_id
    var country_id: Int = 0
    /// created_at
    var created_at: String?
    /// email
    var email: String?
    /// facebook_email
    var facebook_email: String?
    /// facebook_id
    var facebook_id: Int?
    /// facebook_user_token
    var facebook_user_token: String?
    /// favorite_places
    var favorite_places: [FavoritePlace]?
    // swiftlint:disable:previous discouraged_optional_collection
    /// first_name
    var first_name: String = ""
    /// full_name
    var full_name: String?
    /// gender
    var gender: String?
    /// id
    var id: Int = 0
    /// last_log_in
    var last_log_in: String?
    /// last_name
    var last_name: String = ""
    /// links
    var links: [Link]?
    // swiftlint:disable:previous discouraged_optional_collection
    /// location_id
    var location_id: Int = 0
    /// picture
    var picture: String?
    /// rank_beaches
    var rank_beaches: Int?
    /// rank_divesites
    var rank_divesites: Int?
    /// rank_golfcourses
    var rank_golfcourses: Int?
    /// rank_hotels
    var rank_hotels: Int?
    /// rank_locations
    var rank_locations: Int?
    /// rank_restaurants
    var rank_restaurants: Int?
    /// rank_uncountries
    var rank_uncountries: Int?
    /// rank_whss
    var rank_whss: Int?
    /// role
    var role: Int?
    /// score
    var score: Int?
    /// score_beaches
    var score_beaches: Int?
    /// score_divesites
    var score_divesites: Int?
    /// score_golfcourses
    var score_golfcourses: Int?
    /// score_hotels
    var score_hotels: Int?
    /// score_locations
    var score_locations: Int?
    /// score_restaurants
    var score_restaurants: Int?
    /// score_uncountries
    var score_uncountries: Int?
    /// score
    var score_whss: Int?
    /// status
    var status: String?
    /// updated_at
    var updated_at: String?
    /// username
    var username: String?

    /// :nodoc:
    init() { }

    /// Constructor from MTP endpoint data
    init(from: UserJSON) {
    // swiftlint:disable:previous function_body_length
        airport = from.airport
        bio = from.bio
        if let date = from.birthday {
            birthday = DateFormatter.mtpDay.string(from: date)
        } else {
            birthday = nil
        }
        country_id = from.countryId ?? 0
        if let createdAt = from.createdAt {
            created_at = DateFormatter.mtpTime.string(from: createdAt)
        }
        email = from.email
        facebook_email = from.facebookEmail
        facebook_id = from.facebookId
        facebook_user_token = from.facebookUserToken
        // favorite_places = from.favoritePlaces
        first_name = from.firstName
        full_name = from.fullName
        gender = from.gender
        id = from.id
        last_log_in = from.lastLogIn
        last_name = from.lastName
        links = from.links
        location_id = from.locationId ?? 0
        picture = from.picture
        rank_beaches = from.rankBeaches
        rank_divesites = from.rankDivesites
        rank_golfcourses = from.rankGolfcourses
        rank_hotels = from.rankHotels
        rank_locations = from.rankLocations
        rank_restaurants = from.rankRestaurants
        rank_uncountries = from.rankUncountries
        rank_whss = from.rankWhss
        role = from.role
        score = from.score
        score_beaches = from.scoreBeaches
        score_divesites = from.scoreDivesites
        score_golfcourses = from.scoreGolfcourses
        score_hotels = from.scoreHotels
        score_locations = from.scoreLocations
        score_restaurants = from.scoreRestaurants
        score_uncountries = from.scoreUncountries
        score_whss = from.scoreWhss
        status = from.status
        if let updatedAt = from.updatedAt {
            updated_at = DateFormatter.mtpTime.string(from: updatedAt)
        }
        username = from.username
    }
}

/// Reply from the user token update endpoint
struct UserTokenReply: Codable {

    fileprivate struct Data: Codable {

        /// "apn_device_token"
        let type: String
        /// Updated user
        let userId: UncertainValue<Int, String>?
        /// Updated token
        let value: String
        let createdAt: Date
        let updatedAt: Date
        let id: Int
    }

    fileprivate let data: Data
}
