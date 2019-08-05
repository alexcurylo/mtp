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

struct ScorecardRankedUsersWrapper: Codable {

    let beaches: ScorecardRankedUsers?
    let divesites: ScorecardRankedUsers?
    let golfcourses: ScorecardRankedUsers?
    let locations: ScorecardRankedUsers?
    let restaurants: ScorecardRankedUsers?
    let uncountries: ScorecardRankedUsers?
    let whss: ScorecardRankedUsers?
}

struct ScorecardRankedUsers: Codable {

    private enum CodingKeys: String, CodingKey {
        case ageAndCountry = "AgeAndCountry"
        case ageAndGenderAndCountry = "AgeAndGenderAndCountry"
        case country = "Country"
        case genderAndCountry = "GenderAndCountry"
    }

    let ageAndCountry: [Int: ScorecardRankedUser]
    let ageAndGenderAndCountry: [Int: ScorecardRankedUser]
    let country: [ScorecardRankedUser]
    let genderAndCountry: [Int: ScorecardRankedUser]
}

struct ScorecardRankedUser: Codable {

    let data: ScorecardRankedUserJSON
    let rank: Int
    let score: Int
}

struct ScorecardRankedUserJSON: Codable {

    let birthday: Date?
    let country: String?
    let firstName: String
    let fullName: String
    let gender: String
    let id: Int
    let lastName: String
    let location: LocationJSON // still has 30 items
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
    let scoreBeaches: Int?
    let scoreDivesites: Int?
    let scoreGolfcourses: Int?
    let scoreLocations: Int?
    let scoreRestaurants: Int?
    let scoreUncountries: Int?
    let scoreWhss: Int?
    let status: String
}

struct RanksWrapper: Codable {

    let beaches: ScorecardRanks?
    let divesites: ScorecardRanks?
    let golfcourses: ScorecardRanks?
    let locations: ScorecardRanks?
    let restaurants: ScorecardRanks?
    let uncountries: ScorecardRanks?
    let whss: ScorecardRanks?

    var ranks: ScorecardRanks? {
        return beaches ??
               divesites ??
               golfcourses ??
               locations ??
               restaurants ??
               uncountries ??
               whss
    }
}

struct ScorecardRanks: Codable {

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
    let birthday: Date?
    let firstName: String
    let gender: String
    let id: Int
    let lastName: String
    let location: LocationJSON // still has 30 items
    let locationId: Int
    let picture: String?
    let rankBeaches: Int?
    let rankDivesites: Int?
    let rankGolfcourses: Int?
    let rankLocations: Int?
    let rankRestaurants: Int?
    let rankUncountries: Int?
    let rankWhss: Int?
    let scoreBeaches: Int?
    let scoreDivesites: Int?
    let scoreGolfcourses: Int?
    let scoreLocations: Int?
    let scoreRestaurants: Int?
    let scoreUncountries: Int?
    let status: String
}

struct ScorecardLocationJSON: Codable {

    let countryId: Int?
    let countryName: String?
    let id: Int
    let locationName: String?
    let regionId: Int?
    let rank: Int
    let regionName: String?
    let visitors: Int
    let visitorsUn: Int?
}

struct ScorecardJSON: Codable {

    private enum CodingKeys: String, CodingKey {
        case ageLevel = "age-level"
        case labelPairs
        case rank
        case remainingByUser
        case scoreBeaches
        case scoreDivesites
        case scoreGolfcourses
        case scoreLocations
        case scoreRestaurants
        case scoreUncountries
        case scoreWhss
        case type
        case user
        case userId
        //case usersByRank
        case visitedByUser
   }

    let ageLevel: AgeLevel
    let labelPairs: LabelPairs
    let rank: RanksWrapper?
    let remainingByUser: UncertainValue<[Int: ScorecardLocationJSON], [ScorecardLocationJSON]> // usually array if 1...2
    let scoreBeaches: Int?
    let scoreDivesites: Int?
    let scoreGolfcourses: Int?
    let scoreLocations: Int?
    let scoreRestaurants: Int?
    let scoreUncountries: Int?
    let scoreWhss: Int?
    let type: String
    let user: ScorecardUserJSON
    let userId: String
    //let usersByRank: ScorecardRankedUsersWrapper
    let visitedByUser: UncertainValue<[Int: ScorecardLocationJSON], [ScorecardLocationJSON]> // usually array if 1...2
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
        type: \(type)
        user: \(user)
        userId: \(userId)
        /ScorecardJSON >
        """
    }
}

/// Realm representation of a user socrecard
@objcMembers final class Scorecard: Object {

    dynamic var userId: Int = 0
    dynamic var checklistValue: Int = Checklist.beaches.rawValue
    var checklist: Checklist {
        //swiftlint:disable:next force_unwrapping
        get { return Checklist(rawValue: checklistValue)! }
        set { checklistValue = newValue.rawValue }
    }
    dynamic var visited: Int = 0
    dynamic var remaining: Int = 0

    dynamic var age: Int = 0
    dynamic var countryId: Int = 0
    dynamic var gender: String = ""
    dynamic var locationId: Int = 0

    dynamic var ageAndCountry: Int = 0
    dynamic var ageAndGenderAndCountry: Int = 0
    dynamic var country: Int = 0
    dynamic var genderAndCountry: Int = 0

    dynamic var dbKey: String = ""

    let visits = List<Int>()

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "dbKey"
    }

    static func key(list: Checklist, user: Int) -> String {
        return "list=\(list.rawValue)?user=\(user)"
    }

    convenience init(from: ScorecardWrapperJSON) {
        self.init()

        userId = Int(from.data.userId) ?? 0
        checklist = Checklist(key: from.data.type) ?? .beaches
        if let visitedDict = from.data.visitedByUser.tValue {
            visited = visitedDict.count
            visitedDict.forEach { visits.append($0.1.id) }
        } else if let visitedArray = from.data.visitedByUser.uValue {
            visited = visitedArray.count
            visitedArray.forEach { visits.append($0.id) }
        } else {
            visited = 0
        }
        if let remainingDict = from.data.remainingByUser.tValue {
            remaining = remainingDict.count
        } else if let remainingArray = from.data.remainingByUser.uValue {
            remaining = remainingArray.count
        } else {
            remaining = 0
        }

        age = from.data.ageLevel.min
        countryId = from.data.user.location.countryId ?? 0
        locationId = from.data.user.location.id
        gender = from.data.user.gender

        if let ranks = from.data.rank?.ranks {
            ageAndCountry = ranks.ageAndCountry
            ageAndGenderAndCountry = ranks.ageAndGenderAndCountry
            country = ranks.country
            genderAndCountry = ranks.genderAndCountry
        }

        dbKey = Scorecard.key(list: checklist, user: userId)
    }

    func rank(filter: RankingsQuery) -> Int? {
        guard countryId == filter.countryId else { return nil }

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
