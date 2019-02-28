// @copyright Trollwerks Inc.

import RealmSwift

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

enum Age: Int, Codable, CustomStringConvertible {

    case all = 0
    case under20
    case from20to30
    case from30to40
    case from40to50
    case from50to60
    case from60to70
    case from70to80
    case over80

    var description: String {
        switch self {
        case .all: return Localized.allAges()
        case .under20: return Localized.under20()
        case .from20to30: return Localized.ageRange(20, 30)
        case .from30to40: return Localized.ageRange(30, 40)
        case .from40to50: return Localized.ageRange(40, 50)
        case .from50to60: return Localized.ageRange(50, 60)
        case .from60to70: return Localized.ageRange(60, 70)
        case .from70to80: return Localized.ageRange(70, 80)
        case .over80: return Localized.over80()
        }
    }

    var parameter: Int {
        switch self {
        case .all: return 0
        case .under20: return 1
        case .from20to30: return 20
        case .from30to40: return 30
        case .from40to50: return 40
        case .from50to60: return 50
        case .from60to70: return 60
        case .from70to80: return 70
        case .over80: return 80
        }
    }
}

struct RankingsQuery: Codable, Hashable, ServiceProvider {

    static let allLocations = -1

    var checklistType: Checklist
    var page: Int = 1

    var ageGroup: Age = .all
    var country: String?
    var countryId: Int?
    var facebookConnected: Bool = false
    var gender: Gender = .all
    var location: String?
    var locationId: Int?

    func with(page: Int) -> RankingsQuery {
        var withPage = self
        withPage.page = page
        return withPage
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
        return components.joined(separator: Localized.join())
    }

    private var ageDescription: String? {
        return ageGroup != .all ? ageGroup.description : nil
    }

    private var facebookDescription: String? {
        return facebookConnected ? Localized.facebookFriends() : nil
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
            return Localized.allCountries()
        }
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

    var isAllTravelers: Bool {
        if ageGroup != .all { return false }
        if countryId != nil { return false }
        if facebookConnected { return false }
        if gender != .all { return false }
        if locationId != nil { return false }

        return true
    }

    var parameters: [String: String] {
        var parameters: [String: String] = [:]

        parameters["checklistType"] = checklistType.rawValue
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

    mutating func update(with item: Object) -> Bool {
        switch item {
        case let countryItem as Country:
            let newId = countryItem.countryId > 0 ? countryItem.countryId : nil
            guard countryId != newId else { break }
            countryId = newId
            country = newId != nil ? countryItem.countryName : nil
            locationId = countryItem.hasChildren ? RankingsQuery.allLocations : nil
            location = nil
            return true
        case let locationItem as Location:
            let newId = locationItem.id > 0 ? locationItem.id : nil
            guard locationId != newId else { break }
            locationId = newId ?? RankingsQuery.allLocations
            location = newId != nil ? locationItem.locationName : nil
            guard locationItem.countryId > 0 else { return true }
            countryId = locationItem.countryId
            country = locationItem.countryName
            return true
        default:
            log.error("unknown item type selected")
        }
        return false
    }
}
