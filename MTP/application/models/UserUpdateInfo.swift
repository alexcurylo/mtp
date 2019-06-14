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
struct UserUpdate: Codable, Hashable {

    let airport: String?
    let bio: String?
    let birthday: Date
    let countryId: Int
    let createdAt: Date
    let email: String
    let facebookEmail: String?
    let facebookId: Int?
    let facebookUserToken: String?
    // swiftlint:disable:next discouraged_optional_collection
    let favoritePlaces: [FavoritePlace]?
    let firstName: String
    let fullName: String
    let gender: String
    let id: Int
    let lastLogIn: String?
    let lastName: String
    // swiftlint:disable:next discouraged_optional_collection
    let links: [Link]?
    let locationId: Int
    let picture: String?
    let rankBeaches: Int?
    let rankDivesites: Int?
    let rankGolfcourses: Int?
    let rankLocations: Int?
    let rankRestaurants: Int?
    let rankUncountries: Int?
    let rankWhss: Int?
    let role: Int
    let score: Int?
    let scoreBeaches: Int?
    let scoreDivesites: Int?
    let scoreGolfcourses: Int?
    let scoreLocations: Int?
    let scoreRestaurants: Int?
    let scoreUncountries: Int?
    let scoreWhss: Int?
    let status: String
    let updatedAt: Date
    let username: String

    init(from: UserJSON) {
        // log.todo("sort actual names")
        airport = from.airport
        bio = from.bio
        birthday = from.birthday
        countryId = from.countryId
        createdAt = from.createdAt
        email = from.email
        facebookEmail = from.facebookEmail
        facebookId = from.facebookId
        facebookUserToken = from.facebookUserToken
        favoritePlaces = from.favoritePlaces
        firstName = from.firstName
        fullName = from.fullName
        gender = from.gender
        id = from.id
        lastLogIn = from.lastLogIn
        lastName = from.lastName
        links = from.links
        locationId = from.locationId
        picture = from.picture
        rankBeaches = from.rankBeaches
        rankDivesites = from.rankDivesites
        rankGolfcourses = from.rankGolfcourses
        rankLocations = from.rankLocations
        rankRestaurants = from.rankRestaurants
        rankUncountries = from.rankUncountries
        rankWhss = from.rankWhss
        role = from.role
        score = from.score
        scoreBeaches = from.scoreBeaches
        scoreDivesites = from.scoreDivesites
        scoreGolfcourses = from.scoreGolfcourses
        scoreLocations = from.scoreLocations
        scoreRestaurants = from.scoreRestaurants
        scoreUncountries = from.scoreUncountries
        scoreWhss = from.scoreWhss
        status = from.status
        updatedAt = from.updatedAt
        username = from.username
    }
}
