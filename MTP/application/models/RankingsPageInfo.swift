// @copyright Trollwerks Inc.

import RealmSwift

/// Rankings page info received from MTP endpoints
struct RankingsPageInfoJSON: Codable {

    fileprivate let endRank: Int
    fileprivate let endScore: Int
    fileprivate let maxScore: Int
    /// users
    let users: RankingsPageJSON
}

extension RankingsPageInfoJSON: CustomStringConvertible {

    var description: String {
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

    fileprivate let currentPage: Int
    /// data
    let data: [RankedUserJSON]
    fileprivate let firstPageUrl: String
    fileprivate let from: Int? // nil if data empty
    fileprivate let lastPage: Int
    fileprivate let lastPageUrl: String
    fileprivate let nextPageUrl: String?
    fileprivate let path: String
    /// perPage
    let perPage: Int
    fileprivate let prevPageUrl: String?
    fileprivate let to: Int? // nil if data empty
    fileprivate let total: Int
}

extension RankingsPageJSON: CustomStringConvertible {

    var description: String {
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

    fileprivate let birthday: Date?
    fileprivate let country: LocationJSON?
    fileprivate let currentRank: Int
    fileprivate let firstName: String
    /// fullName
    fileprivate let fullName: String
    fileprivate let gender: String
    /// id
    let id: Int
    fileprivate let lastName: String
    fileprivate let location: LocationJSON?
    fileprivate let locationId: Int?
    fileprivate let picture: String?
    fileprivate let rankBeaches: Int?
    fileprivate let rankDivesites: Int?
    fileprivate let rankGolfcourses: Int?
    fileprivate let rankLocations: Int?
    fileprivate let rankRestaurants: Int?
    fileprivate let rankUncountries: Int?
    fileprivate let rankWhss: Int?
    fileprivate let role: Int
    fileprivate let scoreBeaches: Int?
    fileprivate let scoreDivesites: Int?
    fileprivate let scoreGolfcourses: Int?
    fileprivate let scoreLocations: Int?
    fileprivate let scoreRestaurants: Int?
    fileprivate let scoreUncountries: Int?
    fileprivate let scoreWhss: Int?
}

extension RankedUserJSON: CustomStringConvertible {

    var description: String {
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
        location: \(String(describing: location))
        location_id: \(String(describing: locationId))
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

    /// Expected items per page
    static let perPage = 50

    /// lastPage
    dynamic var lastPage: Int = 0
    /// page
    dynamic var page: Int = 0

    /// dbKey
    dynamic var dbKey: String = ""
    /// queryKey
    dynamic var queryKey: String = ""
    /// timestamp
    dynamic var timestamp: TimeInterval = Date().timeIntervalSinceReferenceDate

    /// userIds
    let userIds = List<Int>()

    /// Is this page expired?
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

    /// Initialization by injection
    ///
    /// - Parameters:
    ///   - query: RankingsQuery
    ///   - info: RankingsPageInfoJSON
    convenience init(query: RankingsQuery,
                     info: RankingsPageInfoJSON) {
        self.init()

        queryKey = query.queryKey
        dbKey = query.dbKey

        page = info.users.currentPage
        lastPage = info.users.lastPage
        info.users.data.forEach { userIds.append($0.id) }
    }

    /// Apply timestamp
    func stamp() {
        timestamp = Date().timeIntervalSinceReferenceDate
    }
 }

extension User {

    /// Constructor from MTP endpoint data
    convenience init(from: RankedUserJSON,
                     with existing: User?) {
        self.init()

        airport = existing?.airport ?? ""
        bio = existing?.bio ?? ""
        fullName = from.fullName
        gender = from.gender
        locationName = from.location?.description ?? existing?.locationName ?? ""
        picture = from.picture
        orderBeaches = from.rankBeaches ?? existing?.orderBeaches ?? 0
        orderDivesites = from.rankDivesites ?? existing?.orderDivesites ?? 0
        orderGolfcourses = from.rankGolfcourses ?? existing?.orderGolfcourses ?? 0
        orderLocations = from.rankLocations ?? existing?.orderLocations ?? 0
        orderRestaurants = from.rankRestaurants ?? existing?.orderRestaurants ?? 0
        orderUncountries = from.rankUncountries ?? existing?.orderUncountries ?? 0
        orderWhss = from.rankWhss ?? existing?.orderWhss ?? 0
        userId = from.id
        visitBeaches = from.scoreBeaches ?? existing?.visitBeaches ?? 0
        visitDivesites = from.scoreDivesites ?? existing?.visitDivesites ?? 0
        visitGolfcourses = from.scoreGolfcourses ?? existing?.visitGolfcourses ?? 0
        visitLocations = from.scoreLocations ?? existing?.visitLocations ?? 0
        visitRestaurants = from.scoreRestaurants ?? existing?.visitRestaurants ?? 0
        visitUncountries = from.scoreUncountries ?? existing?.visitUncountries ?? 0
        visitWhss = from.scoreWhss ?? existing?.visitWhss ?? 0

        existing?.linkTexts.forEach { linkTexts.append($0) }
        existing?.linkUrls.forEach { linkUrls.append($0) }
    }
}
