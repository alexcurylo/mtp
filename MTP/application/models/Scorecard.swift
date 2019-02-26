// @copyright Trollwerks Inc.

import RealmSwift

struct ScorecardWrapperJSON: Codable {

    let data: ScorecardJSON
}

struct AgeLevel: Codable {
    let min: Int
    let max: Int
}

struct LabelPairs: Codable {

    let beaches: String
    let divesites: String
    let golfcourses: String
    let locations: String
    let restaurants: String
    let uncountries: String
    let whss: String
}

struct LocationRankedUsersWrapper: Codable {

    let locations: LocationRankedUsers
}

struct LocationRankedUsers: Codable {

    private enum CodingKeys: String, CodingKey {
        case ageAndCountry = "AgeAndCountry"
        case ageAndGenderAndCountry = "AgeAndGenderAndCountry"
        case country = "Country"
        case genderAndCountry = "GenderAndCountry"
    }

    let ageAndCountry: [Int: LocationRankedUser]
    let ageAndGenderAndCountry: [Int: LocationRankedUser]
    let country: [LocationRankedUser]
    let genderAndCountry: [Int: LocationRankedUser] // Dictionary at /me, Array at /users/id
}

struct LocationRankedUser: Codable {

    let data: LocationRankedUserJSON
    let rank: Int
    let score: Int
}

struct LocationRankedUserJSON: Codable {

    let birthday: Date
    let country: String?
    let firstName: String
    let fullName: String
    let gender: String
    let id: Int
    let lastName: String
    let location: LocationJSON // still has 30 items
    let locationId: Int
    let picture: String?
    let rankLocations: Int?
    let role: Int
    let scoreLocations: Int?
    let status: String
}

struct LocationRanksWrapper: Codable {

    let locations: LocationRanks
}

struct LocationRanks: Codable {

    private enum CodingKeys: String, CodingKey {
        case ageAndCountry = "AgeAndCountry"
        case ageAndGenderAndCountry = "AgeAndGenderAndCountry"
        case country = "Country"
        case genderAndCountry = "GenderAndCountry"
    }

    let ageAndCountry: Int
    let ageAndGenderAndCountry: Int
    let country: Int
    let genderAndCountry: Int
}

struct ScorecardUserJSON: Codable {

    let age: Int
    let birthday: Date
    let firstName: String
    let gender: String
    let id: Int
    let lastName: String
    let location: LocationJSON // still has 30 items
    let locationId: Int
    let picture: String?
    let rankLocations: Int?
    let scoreLocations: Int?
    let status: String
}

struct ScorecardLocationJSON: Codable {

    let countryId: Int
    let countryName: String
    let id: Int
    let locationName: String
    let regionId: Int
    let rank: Int
    let regionName: String
    let visitors: Int
    let visitorsUn: Int
}

struct ScorecardJSON: Codable {

    private enum CodingKeys: String, CodingKey {
        case ageLevel = "age-level"
        case labelPairs
        case rank
        case remainingByUser
        case scoreLocations
        case type
        case user
        case userId
        //case usersByRank
        case visitedByUser
   }

    let ageLevel: AgeLevel
    let labelPairs: LabelPairs
    let rank: LocationRanksWrapper
    let remainingByUser: [Int: ScorecardLocationJSON]
    let scoreLocations: Int
    let type: String // always "locations"?
    let user: ScorecardUserJSON
    let userId: UncertainValue<Int, String> // Int at /me, String at /users/id
    //let usersByRank: LocationRankedUsersWrapper
    let visitedByUser: [Int: ScorecardLocationJSON]
}

extension ScorecardJSON: CustomStringConvertible {

    public var description: String {
        return "ScorecardJSON: \(userId)"
    }
}

extension ScorecardJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < ScorecardJSON: \(description):
        ageLevel: \(ageLevel)
        labelPairs: \(labelPairs)
        scoreLocations: \(scoreLocations)
        type: \(type)
        user: \(user)
        userId: \(userId)
        /ScorecardJSON >
        """
    }
}

@objcMembers final class Scorecard: Object {

    dynamic var userId: Int = 0

    dynamic var age: Int = 0
    dynamic var countryId: Int = 0
    dynamic var gender: String = ""
    dynamic var locationId: Int = 0

    dynamic var ageAndCountry: Int = 0
    dynamic var ageAndGenderAndCountry: Int = 0
    dynamic var country: Int = 0
    dynamic var genderAndCountry: Int = 0

    override static func primaryKey() -> String? {
        return "userId"
    }

    convenience init(from: ScorecardWrapperJSON) {
        self.init()

        userId = from.data.userId.intValue ?? 0

        age = from.data.ageLevel.min
        countryId = from.data.user.location.countryId
        locationId = from.data.user.location.id
        gender = from.data.user.gender

        let ranks = from.data.rank.locations
        ageAndCountry = ranks.ageAndCountry
        ageAndGenderAndCountry = ranks.ageAndGenderAndCountry
        country = ranks.country
        genderAndCountry = ranks.genderAndCountry
    }

    func rank(filter: RankingsQuery) -> Int? {
        guard countryId == filter.countryId,
              locationId == filter.locationId else { return nil }

        let hasAge = filter.ageGroup != .all
        let ageMatches = filter.ageGroup.parameter == age
        let hasGender = filter.gender != .all
        let genderMatches = filter.gender.rawValue == gender
        switch (hasAge, hasGender) {
        case (false, false):
            return country
        case (true, false):
            return ageMatches ? ageAndCountry : nil
        case (false, true):
            return genderMatches ? genderAndCountry : nil
        case (true, true):
            return ageMatches && genderMatches ? ageAndGenderAndCountry : nil
        }
    }
}
