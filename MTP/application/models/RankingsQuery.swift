// @copyright Trollwerks Inc.

import Foundation

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
        users: \(users)
        /RankingsPageInfoJSON >
        """
    }
}

struct RankingsPageJSON: Codable {

    let currentPage: Int
    let data: [RankedUserJSON]
    let firstPageUrl: String
    let from: Int
    let lastPage: Int
    let lastPageUrl: String
    let nextPageUrl: String?
    let path: String
    let perPage: Int
    let prevPageUrl: String?
    let to: Int
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
        data: \(data)
        firstPageUrl: \(firstPageUrl)
        from: \(from)
        lastPage: \(lastPage)
        lastPageUrl: \(lastPageUrl)
        nextPageUrl: \(String(describing: nextPageUrl))
        path: \(path)
        perPage: \(perPage)
        prevPageUrl: \(String(describing: prevPageUrl))
        to: \(to)
        total: \(total)
        /RankingsPageUsers >
        """
    }
}

struct RankedUserJSON: Codable {

    let birthday: Date
    let country: LocationJSON?
    let currentRank: Int
    let firstName: String
    let fullName: String
    let gender: String
    let id: Int
    let lastName: String
    let location: LocationJSON // still has 30 items
    let locationId: Int
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
        birthday: \(birthday)
        country: \(String(describing: country))
        currentRank: \(currentRank)
        first_name: \(firstName)
        full_name: \(fullName)
        gender: \(gender)
        id: \(id)
        last_name: \(lastName)
        location: \(location)
        location_id: \(locationId)
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

struct RankingsQuery: Codable, Hashable {

    enum Gender: String, Codable, CustomStringConvertible {
        case all = ""
        case female = "F"
        case male = "M"

        var description: String {
            switch self {
            case .all: return "all"
            case .female: return Localized.female()
            case .male: return Localized.male()
            }
        }
    }

    var checklistType: Checklist
    var page: Int = 1

    var ageGroup: Int?
    var country: String?
    var countryId: Int?
    var facebookConnected: Bool = false
    var gender: Gender = .all
    var location: String?
    var locationId: Int?
}

extension RankingsQuery: CustomStringConvertible {

    var description: String {
        let components: [String] = [
            locationDescription,
            genderDescription,
            ageDescription,
            facebookDescription
        ].compactMap { $0 }.filter { !$0.isEmpty }
        return components.joined(separator: Localized.join())
    }

    private var ageDescription: String? {
        return nil
    }

    private var facebookDescription: String? {
        return facebookConnected ? Localized.facebookFriends() : nil
    }

    private var genderDescription: String? {
        return gender != .all ? gender.description : nil
    }

    private var locationDescription: String {
        return Localized.allLocations()
    }
}

extension RankingsQuery: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < RankingsQuery: \(description):
        checklistType: \(checklistType)
        page: \(page)
        ageGroup: \(String(describing: ageGroup))
        country: \(String(describing: country))
        countryId: \(String(describing: countryId))
        facebookConnected: \(facebookConnected)
        gender: \(gender)
        location: \(String(describing: location))
        locationId: \(String(describing: locationId))
        /RankingsQuery >
        """
    }
}

extension RankingsQuery {

    init(list: Checklist = .locations) {
        checklistType = list
    }

    var key: String {
        return checklistType.rawValue
    }

    var parameters: [String: String] {
        var parameters: [String: String] = [:]

        parameters["checklistType"] = checklistType.rawValue
        parameters["page"] = String(page)

        if let country = country {
            parameters["country"] = country
        }
        if let countryId = countryId {
            parameters["country_id"] = String(countryId)
        }
        if facebookConnected {
            parameters["facebookConnected"] = "true"
        }
        if gender != .all {
            parameters["gender"] = gender.rawValue
        }
        if let location = location {
            parameters["location"] = location
        }
        if let locationId = locationId {
            parameters["location_id"] = String(locationId)
        }

        return parameters
    }
}
