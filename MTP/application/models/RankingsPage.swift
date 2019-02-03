// @copyright Trollwerks Inc.

import Foundation

struct RankingsPage: Codable {

    let endRank: Int
    let endScore: Int
    let maxScore: Int
    let users: RankingsPageUsers
}

extension RankingsPage: CustomStringConvertible {

    public var description: String {
        return "RankingsPage: \(endRank) \(endScore)"
    }
}

extension RankingsPage: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < RankingsPage: \(description):
        endRank: \(endRank)
        endScore: \(endScore)
        maxScore: \(maxScore)
        users: \(users)
        /RankingsPage >
        """
    }
}

struct RankingsPageUsers: Codable {

    let currentPage: Int
    let data: [RankingsUser]
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

extension RankingsPageUsers: CustomStringConvertible {

    public var description: String {
        return "RankingsPageUsers: \(currentPage) \(lastPage)"
    }
}

extension RankingsPageUsers: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < RankingsPageUsers: \(description):
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

struct RankingsUser: Codable {

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

extension RankingsUser: CustomStringConvertible {

    public var description: String {
        return "RankingsUser: \(currentRank) \(fullName)"
    }
}

extension RankingsUser: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < RankingsUser: \(description):
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
        /RankingsUser >
        """
    }
}

struct RankingsPageSpec: Hashable {

    enum Gender: String {
        case male = "M"
        case female = "F"
    }

    let checklistType: Checklist
    let page: Int = 1

    let gender: Gender? = nil
    let country: String? = nil
    let countryId: Int? = nil
    let location: String? = nil
    let locationId: Int? = nil
    let ageGroup: Int? = nil
    // swiftlint:disable:next discouraged_optional_boolean
    let facebookConnected: Bool? = nil
}

extension RankingsPageSpec {

    init(list: Checklist) {
        checklistType = list
    }

    var key: String {
        return checklistType.rawValue
    }

    var parameters: [String: String] {
        var parameters: [String: String] = [:]

        parameters["checklistType"] = checklistType.rawValue
        parameters["page"] = String(page)
        if let gender = gender {
            parameters["gender"] = gender.rawValue
        }
        if let country = country {
            parameters["country"] = country
        }
        if let countryId = countryId {
            parameters["country_id"] = String(countryId)
        }
        if let location = location {
            parameters["location"] = location
        }
        if let locationId = locationId {
            parameters["location_id"] = String(locationId)
        }
        if let facebookConnected = facebookConnected {
            parameters["facebookConnected"] = String(facebookConnected)
        }

        return parameters
    }
}
