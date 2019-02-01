// @copyright Trollwerks Inc.

import Nuke

struct User: Codable {

    let airport: String?
    let bio: String?
    let birthday: Date
    let country: Country
    let countryId: UncertainValue<Int, String> // Int in staging, String in production
    let createdAt: Date
    let email: String
    let facebookEmail: String?
    let facebookId: UncertainValue<Int, String> // Int in staging, String in production
    let facebookUserToken: String?
    let favoritePlaces: [FavoritePlace]
    let firstName: String
    let fullName: String
    let gender: String
    let id: Int
    let lastLogIn: String?
    let lastName: String
    let location: Country
    let links: [Link]
    let locationId: UncertainValue<Int, String> // Int in staging, String in production
    let picture: String?
    let rankBeaches: Int
    let rankDivesites: Int
    let rankGolfcourses: Int
    let rankLocations: Int
    let rankRestaurants: Int
    let rankUncountries: Int
    let rankWhss: Int
    let role: Int
    let score: UncertainValue<Int, String> // Int in staging, String in production
    let scoreBeaches: UncertainValue<Int, String> // Int in staging, String in production
    let scoreDivesites: UncertainValue<Int, String> // Int in staging, String in production
    let scoreGolfcourses: UncertainValue<Int, String> // Int in staging, String in production
    let scoreLocations: UncertainValue<Int, String> // Int in staging, String in production
    let scoreRestaurants: UncertainValue<Int, String> // Int in staging, String in production
    let scoreUncountries: UncertainValue<Int, String> // Int in staging, String in production
    let scoreWhss: UncertainValue<Int, String> // Int in staging, String in production
    let status: String
    let token: String? // found only in login response
    let updatedAt: Date
    let username: String
}

extension User: CustomStringConvertible {

    public var description: String {
        return "\(username) (\(id))"
    }
}

extension User: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < User: \(description):
            airport: \(String(describing: airport))
            bio: \(String(describing: bio))
            birthday: \(birthday)
            country: \(country.debugDescription)
            country_id: \(countryId)
            created_at: \(createdAt)
            email: \(email)
            facebook_email: \(String(describing: facebookEmail))
            facebook_id: \(String(describing: facebookId))
            facebook_user_token: \(String(describing: facebookUserToken))
            favorite_places: \(favoritePlaces.debugDescription)
            first_name: \(firstName)
            full_name: \(fullName)
            gender: \(gender)
            id: \(id)
            last_log_in: \(String(describing: lastLogIn))
            last_name: \(lastName)
            location: \(location.debugDescription)
            links: \(links.debugDescription)
            location_id: \(locationId)
            picture: \(String(describing: picture))
            rankBeaches: \(rankBeaches)
            rankDivesites: \(rankDivesites)
            rankGolfcourses: \(rankGolfcourses)
            rankLocations: \(rankLocations)
            rankRestaurants: \(rankRestaurants)
            rankUncountries: \(rankUncountries)
            rankWhss: \(rankWhss)
            role: \(role)
            score: \(score)
            score_beaches: \(scoreBeaches)
            score_divesites: \(scoreDivesites)
            score_golfcourses: \(scoreGolfcourses)
            score_locations: \(scoreLocations)
            score_restaurants: \(scoreRestaurants)
            score_uncountries: \(scoreUncountries)
            score_whss: \(scoreWhss)
            status: \(status)
            token: \(String(describing: token))
            updated_at: \(updatedAt)
            username: \(username)
        /User >
        """
    }
}

struct FavoritePlace: Codable {

    let id: String?
    let type: String?
}

extension FavoritePlace: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return debugDescription
    }

    public var debugDescription: String {
        return """
        < Favorite Place:
            id \(String(describing: id))
            type \(String(describing: type))>
        """
    }
}

struct Link: Codable {

    let text: String
    let url: String
}

extension Link: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return debugDescription
    }

    public var debugDescription: String {
        return "< Link: text \(text) url \(url)>"
    }
}

extension User {

    var imageUrl: URL? {
        guard let uuid = picture, !uuid.isEmpty else { return nil }
        let link = "https://mtp.travel/api/files/preview?uuid=\(uuid)&size=thumb"
        return URL(string: link)
    }

    var placeholder: UIImage? {
        switch gender {
        case "F":
            return R.image.placeholderFemaleThumb()
        case "M":
            return R.image.placeholderMaleThumb()
        default:
            return R.image.placeholderThumb()
        }
    }

    var visited: Int {
        return scoreLocations.intValue ?? 0
    }

    var remaining: Int {
        return Location.count - visited
    }
}

enum Gender: Int, Codable {
    case all
    case female
    case male
}

extension Gender: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        switch self {
        case .all: return ""
        case .female: return Localized.female()
        case .male: return Localized.male()
        }
    }

    public var debugDescription: String {
        return String(rawValue)
    }
}

struct UserFilter: Codable, Equatable {

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

extension UIImageView {

    func setImage(for user: User?) {
        let placeholder = user?.placeholder
        guard let url = user?.imageUrl else {
            image = placeholder
            return
        }

        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions(
                placeholder: placeholder,
                transition: .fadeIn(duration: 0.2)
            ),
            into: self
        )
    }
}
