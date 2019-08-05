// @copyright Trollwerks Inc.

import RealmSwift

/// Rankings page info received from MTP endpoints
struct RankingsPageInfoJSON: Codable {

    let endRank: Int
    let endScore: Int
    let maxScore: Int
    let users: RankingsPageJSON
}

extension RankingsPageInfoJSON: CustomStringConvertible {

    public var description: String {
        return "RankingsPageInfoJSON: \(endRank) \(endScore)"
    }
}

extension RankingsPageInfoJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < RankingsPageInfoJSON: \(description):
        endRank: \(endRank)
        endScore: \(endScore)
        maxScore: \(maxScore)
        users: \(users.debugDescription)
        /RankingsPageInfoJSON >
        """
    }
}

/// Rankngs page received from MTP endpoints
struct RankingsPageJSON: Codable {

    let currentPage: Int
    let data: [RankedUserJSON]
    let firstPageUrl: String
    let from: Int? // nil if data empty
    let lastPage: Int
    let lastPageUrl: String
    let nextPageUrl: String?
    let path: String
    let perPage: Int
    let prevPageUrl: String?
    let to: Int? // nil if data empty
    let total: Int
}

extension RankingsPageJSON: CustomStringConvertible {

    public var description: String {
        return "RankingsPageJSON: \(currentPage) \(lastPage)"
    }
}

extension RankingsPageJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < RankingsPageJSON: \(description):
        currentPage: \(currentPage)
        data: \(data.debugDescription)
        firstPageUrl: \(firstPageUrl)
        from: \(String(describing: from))
        lastPage: \(lastPage)
        lastPageUrl: \(lastPageUrl)
        nextPageUrl: \(String(describing: nextPageUrl))
        path: \(path)
        perPage: \(perPage)
        prevPageUrl: \(String(describing: prevPageUrl))
        to: \(String(describing: to))
        total: \(total)
        /RankingsPageJSON >
        """
    }
}

/// User info contained in ranking page
struct RankedUserJSON: Codable {

    let birthday: Date?
    let country: LocationJSON?
    let currentRank: Int
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
}

extension RankedUserJSON: CustomStringConvertible {

    public var description: String {
        return "RankedUserJSON: \(currentRank) \(fullName)"
    }
}

extension RankedUserJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < RankedUserJSON: \(description):
        birthday: \(String(describing: birthday))
        country: \(String(describing: country))
        currentRank: \(currentRank)
        first_name: \(firstName)
        full_name: \(fullName)
        gender: \(gender)
        id: \(id)
        last_name: \(lastName)
        location: \(location)
        location_id: \(locationId)
        picture: \(String(describing: picture))
        rankBeaches: \(String(describing: rankBeaches))
        rankDivesites: \(String(describing: rankDivesites))
        rankGolfcourses: \(String(describing: rankGolfcourses))
        rankLocations: \(String(describing: rankLocations))
        rankRestaurants: \(String(describing: rankRestaurants))
        rankUncountries: \(String(describing: rankUncountries))
        rankWhss: \(String(describing: rankWhss))
        role: \(role)
        scoreBeaches: \(String(describing: scoreBeaches))
        scoreDivesites: \(String(describing: scoreDivesites))
        scoreGolfcourses: \(String(describing: scoreGolfcourses))
        scoreLocations: \(String(describing: scoreLocations))
        scoreRestaurants: \(String(describing: scoreRestaurants))
        scoreUncountries: \(String(describing: scoreUncountries))
        scoreWhss: \(String(describing: scoreWhss))
        /RankedUserJSON >
        """
    }
}

/// Realm representation of a rankings page
@objcMembers final class RankingsPageInfo: Object {

    static let perPage = 50

    dynamic var lastPage: Int = 0
    dynamic var page: Int = 0

    dynamic var dbKey: String = ""
    dynamic var queryKey: String = ""
    dynamic var timestamp: TimeInterval = Date().timeIntervalSinceReferenceDate

    let userIds = List<Int>()

    var expired: Bool {
        let validTime = TimeInterval(Timestamps.rankUpdateMinutes * 60)
        let expired = Date().timeIntervalSinceReferenceDate > timestamp + validTime
        return expired
    }

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "dbKey"
    }

    convenience init(query: RankingsQuery,
                     info: RankingsPageInfoJSON) {
        self.init()

        queryKey = query.queryKey
        dbKey = query.dbKey

        page = info.users.currentPage
        lastPage = info.users.lastPage
        info.users.data.forEach { userIds.append($0.id) }
    }

    func stamp() {
        timestamp = Date().timeIntervalSinceReferenceDate
    }
 }
