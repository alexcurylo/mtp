// @copyright Trollwerks Inc.

import RealmSwift

/// Enclosing results from API
struct ScorecardWrapperJSON: Codable {

    /// results
    let data: ScorecardJSON
}

private struct AgeLevel: Codable {

    let min: Int
    let max: Int
}

private struct LabelPairs: Codable {

    let beaches: String
    let divesites: String
    let golfcourses: String
    let hotels: String
    let locations: String
    let restaurants: String
    let uncountries: String
    let whss: String
}

private struct ScorecardRankedUsersWrapper: Codable {

    let beaches: ScorecardRankedUsers?
    let divesites: ScorecardRankedUsers?
    let golfcourses: ScorecardRankedUsers?
    let hotels: ScorecardRankedUsers?
    let locations: ScorecardRankedUsers?
    let restaurants: ScorecardRankedUsers?
    let uncountries: ScorecardRankedUsers?
    let whss: ScorecardRankedUsers?
}

private struct ScorecardRankedUsers: Codable {

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

private struct ScorecardRankedUser: Codable {

    let data: ScorecardRankedUserJSON
    let rank: Int
    let score: Int
}

private struct ScorecardRankedUserJSON: Codable {

    let birthday: Date?
    let country: String?
    let firstName: String
    /// fullName
    let fullName: String
    let gender: String?
    /// id
    let id: Int
    let lastName: String
    let location: PlaceLocation?
    let locationId: Int?
    let picture: String?
    let rankBeaches: Int?
    let rankDivesites: Int?
    let rankGolfcourses: Int?
    let rankHotels: Int?
    let rankLocations: Int?
    let rankRestaurants: Int?
    let rankUncountries: Int?
    let rankWhss: Int?
    let scoreBeaches: Int?
    let scoreDivesites: Int?
    let scoreGolfcourses: Int?
    let scoreHotels: Int?
    let scoreLocations: Int?
    let scoreRestaurants: Int?
    let scoreUncountries: Int?
    let scoreWhss: Int?
    let status: String
}

private struct RanksWrapper: Codable {

    let beaches: ScorecardRanks?
    let divesites: ScorecardRanks?
    let golfcourses: ScorecardRanks?
    let hotels: ScorecardRanks?
    let locations: ScorecardRanks?
    let restaurants: ScorecardRanks?
    let uncountries: ScorecardRanks?
    let whss: ScorecardRanks?

    var ranks: ScorecardRanks? {
        if beaches != nil { return beaches }
        if divesites != nil { return divesites }
        if golfcourses != nil { return golfcourses }
        if hotels != nil { return hotels }
        if locations != nil { return locations }
        if restaurants != nil { return restaurants }
        if uncountries != nil { return uncountries }
        return whss
    }
}

private struct ScorecardRanks: Codable {

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

private struct ScorecardUserJSON: Codable {

    let age: Int
    let birthday: Date?
    let firstName: String
    let gender: String
    let id: Int
    let lastName: String
    let location: PlaceLocation?
    let locationId: Int?
    let picture: String?
    let rankBeaches: Int?
    let rankDivesites: Int?
    let rankGolfcourses: Int?
    let rankHotels: Int?
    let rankLocations: Int?
    let rankRestaurants: Int?
    let rankUncountries: Int?
    let rankWhss: Int?
    let scoreBeaches: Int?
    let scoreDivesites: Int?
    let scoreGolfcourses: Int?
    let scoreHotels: Int?
    let scoreLocations: Int?
    let scoreRestaurants: Int?
    let scoreUncountries: Int?
    let status: String
}

private struct ScorecardLocationJSON: Codable {

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

/// Reply from the scorecard endpoints
struct ScorecardJSON: Codable {

    private enum CodingKeys: String, CodingKey {
        case ageLevel = "age-level"
        case labelPairs
        case rank
        case remainingByUser
        case scoreBeaches
        case scoreDivesites
        case scoreGolfcourses
        case scoreHotels
        case scoreLocations
        case scoreRestaurants
        case scoreUncountries
        case scoreWhss
        case type
        case user
        case userId
        // case usersByRank
        case visitedByUser
    }

    fileprivate let ageLevel: AgeLevel
    fileprivate let labelPairs: LabelPairs
    fileprivate let rank: RanksWrapper?
    // usually array if 1...2
    fileprivate let remainingByUser: UncertainValue<[Int: ScorecardLocationJSON], [ScorecardLocationJSON]>
    fileprivate let scoreBeaches: Int?
    fileprivate let scoreDivesites: Int?
    fileprivate let scoreGolfcourses: Int?
    fileprivate let scoreHotels: Int?
    fileprivate let scoreLocations: Int?
    fileprivate let scoreRestaurants: Int?
    fileprivate let scoreUncountries: Int?
    fileprivate let scoreWhss: Int?
    /// type
    let type: String
    fileprivate let user: ScorecardUserJSON
    /// userId
    let userId: String
    // fileprivate let usersByRank: ScorecardRankedUsersWrapper
     // usually array if 1...2
    fileprivate let visitedByUser: UncertainValue<[Int: ScorecardLocationJSON], [ScorecardLocationJSON]>
}

extension ScorecardJSON: CustomStringConvertible {

    var description: String {
        "ScorecardJSON: \(userId)"
    }
}

extension ScorecardJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        """
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

    /// userId
    dynamic var userId: Int = 0
    /// checklistValue
    dynamic var checklistValue: Int = Checklist.beaches.rawValue
    /// checklist
    var checklist: Checklist {
        // swiftlint:disable:next force_unwrapping
        get { Checklist(rawValue: checklistValue)! }
        set { checklistValue = newValue.rawValue }
    }
    /// visited
    dynamic var visited: Int = 0
    /// remaining
    dynamic var remaining: Int = 0

    /// age
    dynamic var age: Int = 0
    /// countryId
    dynamic var countryId: Int = 0
    /// gender
    dynamic var gender: String = ""
    /// locationId
    dynamic var locationId: Int = 0

    /// ageAndCountry
    dynamic var ageAndCountry: Int = 0
    /// ageAndGenderAndCountry
    dynamic var ageAndGenderAndCountry: Int = 0
    /// country
    dynamic var country: Int = 0
    /// genderAndCountry
    dynamic var genderAndCountry: Int = 0

    /// dbKey
    dynamic var dbKey: String = ""

    /// visits
    let visits = List<Int>()

    /// :nodoc:
    override static func primaryKey() -> String? {
        "dbKey"
    }

    /// Unique key for database
    /// - Parameter item: Item
    /// - Returns: Unique key
    static func key(list: Checklist, user: Int) -> String {
        "list=\(list.rawValue)?user=\(user)"
    }

    /// Constructor from MTP endpoint data
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
        countryId = from.data.user.location?.countryId ?? 0
        locationId = from.data.user.location?.id ?? 0
        gender = from.data.user.gender

        if let ranks = from.data.rank?.ranks {
            ageAndCountry = ranks.ageAndCountry
            ageAndGenderAndCountry = ranks.ageAndGenderAndCountry
            country = ranks.country
            genderAndCountry = ranks.genderAndCountry
        }

        dbKey = Scorecard.key(list: checklist, user: userId)
    }

    /// Rank in query if matches
    /// - Parameter filter: Filter
    /// - Returns: Rank if present
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
