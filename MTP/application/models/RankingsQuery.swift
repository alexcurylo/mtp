// @copyright Trollwerks Inc.

import Foundation

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

struct RankingsQuery: Codable, Hashable {

    var checklistType: Checklist
    var page: Int = 1

    var ageGroup: Age = .all
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
        return ageGroup != .all ? ageGroup.description : nil
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

    var parameters: [String: String] {
        var parameters: [String: String] = [:]

        parameters["checklistType"] = checklistType.rawValue
        parameters["page"] = String(page)

        if ageGroup != .all {
            parameters["ageGroup"] = String(ageGroup.parameter)
        }
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
