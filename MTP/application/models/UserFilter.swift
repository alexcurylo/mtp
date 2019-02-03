// @copyright Trollwerks Inc.

import Foundation

struct UserFilter: Codable, Equatable, ServiceProvider {

    var countryId: Int?
    var provinceId: Int?
    var gender: Gender = .all
    var ageMin: Int?
    var ageMax: Int?
    var facebook: Bool = false
}

extension UserFilter: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return debugDescription
    }

    public var debugDescription: String {
        let components: [String] = [
            locationDescription,
            genderDescription,
            ageDescription,
            facebookDescription
        ].compactMap { $0 }.filter { !$0.isEmpty }
        return components.joined(separator: Localized.join())
    }

    private var locationDescription: String {
        log.todo("UserFilter.location")
        return Localized.allLocations()
    }

    private var genderDescription: String? {
        return gender != .all ? gender.description : nil
    }

    private var ageDescription: String? {
        log.todo("UserFilter.ageDescription")
        return nil
    }

    private var facebookDescription: String? {
        return facebook ? Localized.facebookFriends() : nil
    }
}

enum Gender: Int, Codable {

    case all
    case female
    case male
}

extension Gender: CustomStringConvertible {

    public var description: String {
        switch self {
        case .all: return ""
        case .female: return Localized.female()
        case .male: return Localized.male()
        }
    }
}

extension Gender: CustomDebugStringConvertible {

    public var debugDescription: String {
        return String(rawValue)
    }
}
