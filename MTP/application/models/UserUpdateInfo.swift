// @copyright Trollwerks Inc.

import Foundation

struct UserUpdateInfo: Codable {

    let code: Int
    let message: String
    let user: UserJSON

    var isSuccess: Bool {
        return code == 200
    }
}

// expect everything in UserJSON except country, location structs
struct UserUpdate: Codable, Hashable, UserAvatar {

    var airport: String?
    var bio: String?
    var birthday: String = ""
    var country_id: Int = 0
    var created_at: String = ""
    var email: String = ""
    var facebook_email: String?
    var facebook_id: Int?
    var facebook_user_token: String?
    // swiftlint:disable:next discouraged_optional_collection
    var favorite_places: [FavoritePlace]?
    var first_name: String = ""
    var full_name: String = ""
    var gender: String = ""
    var id: Int = 0
    var last_log_in: String?
    var last_name: String = ""
    // swiftlint:disable:next discouraged_optional_collection
    var links: [Link]?
    var location_id: Int = 0
    var picture: String?
    var rank_beaches: Int?
    var rank_divesites: Int?
    var rank_golfcourses: Int?
    var rank_locations: Int?
    var rank_restaurants: Int?
    var rank_uncountries: Int?
    var rank_whss: Int?
    var role: Int = 0
    var score: Int?
    var score_beaches: Int?
    var score_divesites: Int?
    var score_golfcourses: Int?
    var score_locations: Int?
    var score_restaurants: Int?
    var score_uncountries: Int?
    var score_whss: Int?
    var status: String = ""
    var updated_at: String = ""
    var username: String = ""

    init() { }

    init(from: UserJSON) {
        airport = from.airport
        bio = from.bio
        birthday = DateFormatter.mtpDay.string(from: from.birthday)
        country_id = from.countryId
        created_at = DateFormatter.mtpTime.string(from: from.createdAt)
        email = from.email
        facebook_email = from.facebookEmail
        facebook_id = from.facebookId
        facebook_user_token = from.facebookUserToken
        //favorite_places = from.favoritePlaces
        first_name = from.firstName
        full_name = from.fullName
        gender = from.gender
        id = from.id
        last_log_in = from.lastLogIn
        last_name = from.lastName
        links = from.links
        location_id = from.locationId
        picture = from.picture
        rank_beaches = from.rankBeaches
        rank_divesites = from.rankDivesites
        rank_golfcourses = from.rankGolfcourses
        rank_locations = from.rankLocations
        rank_restaurants = from.rankRestaurants
        rank_uncountries = from.rankUncountries
        rank_whss = from.rankWhss
        role = from.role
        score = from.score
        score_beaches = from.scoreBeaches
        score_divesites = from.scoreDivesites
        score_golfcourses = from.scoreGolfcourses
        score_locations = from.scoreLocations
        score_restaurants = from.scoreRestaurants
        score_uncountries = from.scoreUncountries
        score_whss = from.scoreWhss
        status = from.status
        updated_at = DateFormatter.mtpTime.string(from: from.updatedAt)
        username = from.username
    }
}
