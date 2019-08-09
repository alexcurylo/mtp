// @copyright Trollwerks Inc.

import RealmSwift

/// Gender field in all API endpoints
enum Gender: String, Codable, CustomStringConvertible {

    /// All
    case all = ""
    /// Female
    case female = "F"
    /// Male
    case male = "M"
    /// Unknown
    case unknown = "U"

    var description: String {
        switch self {
        case .all: return "all"
        case .female: return L.female()
        case .male: return L.male()
        case .unknown: return L.preferNot()
        }
    }
}

/// Age group for ranking queries
enum Age: Int, CaseIterable, Codable, CustomStringConvertible {

    /// all
    case all = 0
    /// under20
    case under20
    /// from20to29
    case from20to29
    /// from30to39
    case from30to39
    /// from40to49
    case from40to49
    /// from50to59
    case from50to59
    /// from60to69
    case from60to69
    /// from70to79
    case from70to79
    /// over79
    case over79

    var description: String {
        switch self {
        case .all: return L.allAges()
        case .under20: return L.under20()
        case .from20to29: return L.ageRange(20, 29)
        case .from30to39: return L.ageRange(30, 39)
        case .from40to49: return L.ageRange(40, 49)
        case .from50to59: return L.ageRange(50, 59)
        case .from60to69: return L.ageRange(60, 69)
        case .from70to79: return L.ageRange(70, 79)
        case .over79: return L.over79()
        }
    }

    /// Integer value for query
    var parameter: Int {
        switch self {
        case .all: return 0
        case .under20: return 1
        case .from20to29: return 20
        case .from30to39: return 30
        case .from40to49: return 40
        case .from50to59: return 50
        case .from60to69: return 60
        case .from70to79: return 70
        case .over79: return 80
        }
    }
}

/// Rankings query for API endpoints
struct RankingsQuery: Codable, Hashable, ServiceProvider {

    /// Constant for all locations
    static let allLocations = -1

    /// checklistKey
    var checklistKey: String
    fileprivate var page: Int = 1

    /// ageGroup
    var ageGroup: Age = .all
    fileprivate var country: String?
    /// countryId
    var countryId: Int?
    /// facebookConnected
    var facebookConnected: Bool = false
    /// gender
    var gender: Gender = .all
    fileprivate var location: String?
    /// locationId
    var locationId: Int?

    /// Copy changing list and page
    ///
    /// - Parameters:
    ///   - list: Checklist
    ///   - page: Index
    /// - Returns: New query
    func with(list: Checklist? = nil,
              page: Int = 1) -> RankingsQuery {
        var withList = self
        if let list = list {
            withList.checklistKey = list.key
        }
        withList.page = page
        return withList
    }

    /// Initalize for checklist
    ///
    /// - Parameter list: Checklist
    init(list: Checklist = .locations) {
        checklistKey = list.key
    }
}

extension RankingsQuery: CustomStringConvertible {

    var description: String {
        let components: [String] = [
            locationDescription,
            genderDescription,
            ageDescription,
            facebookDescription
        ].compactMap { $0 }.filter { !$0.isEmpty }
        return components.joined(separator: L.join())
    }

    private var ageDescription: String? {
        return ageGroup != .all ? ageGroup.description : nil
    }

    private var facebookDescription: String? {
        return facebookConnected ? L.facebookFriends() : nil
    }

    private var genderDescription: String? {
        return gender != .all ? gender.description : nil
    }

    private var locationDescription: String {
        switch (country, location) {
        case (_, let location?):
            return location
        case (let country?, _):
            return country
        default:
            return L.allCountries()
        }
    }
}

extension RankingsQuery: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < RankingsQuery: \(description):
        checklistKey: \(checklistKey)
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

    /// Checklist this query is for
    var checklist: Checklist {
        // swiftlint:disable:next force_unwrapping
        return Checklist(key: checklistKey)!
    }

    /// Query key
    var queryKey: String {
        let params = parameters
        let queryKey = params.keys
                             .sorted()
                             .compactMap { key -> String? in
                                key == "page" ? nil : "\(key)=\(params[key] ?? "")"
                             }
                             .joined(separator: "?")
        return queryKey
    }

    /// Unique storage key
    var dbKey: String {
        let params = parameters
        let dbKey = params.keys
                          .sorted()
                          .compactMap { key -> String? in
                             "\(key)=\(params[key] ?? "")"
                          }
                          .joined(separator: "?")
        return dbKey
    }

    /// Convenience accessor for overall rankings query
    var isAllTravelers: Bool {
        if ageGroup != .all { return false }
        if countryId != nil { return false }
        if facebookConnected { return false }
        if gender != .all { return false }
        if locationId != nil { return false }

        return true
    }

    /// Provides API parameters
    var parameters: [String: String] {
        var parameters: [String: String] = [:]

        parameters["checklistType"] = checklistKey
        parameters["page"] = String(page)

        if ageGroup != .all {
            parameters["ageGroup"] = String(ageGroup.parameter)
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
        switch locationId {
        case let id? where id > 0:
            parameters["location_id"] = String(id)
        case RankingsQuery.allLocations:
            parameters["location_id"] = "all"
        default:
            break
        }

        return parameters
    }

    /// Update with new geography
    ///
    /// - Parameter item: Country or Location expected
    /// - Returns: Success
    mutating func update(with item: Object) -> Bool {
        switch item {
        case let countryItem as Country:
            let newId = countryItem.countryId > 0 ? countryItem.countryId : nil
            guard countryId != newId else { break }
            countryId = newId
            country = newId != nil ? countryItem.placeCountry : nil
            locationId = countryItem.hasChildren ? RankingsQuery.allLocations : nil
            location = nil
            return true
        case let locationItem as Location:
            let newId = locationItem.placeId > 0 ? locationItem.placeId : nil
            guard locationId != newId else { break }
            locationId = newId ?? RankingsQuery.allLocations
            location = newId != nil ? locationItem.placeTitle : nil
            guard locationItem.countryId > 0 else { return true }
            countryId = locationItem.countryId
            country = locationItem.placeCountry
            return true
        default:
            log.error("unknown item type selected")
        }
        return false
    }
}
