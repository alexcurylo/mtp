// @copyright Trollwerks Inc.

import RealmSwift

protocol UserAvatar {

    var gender: String { get }
    var picture: String? { get }
}

protocol UserInfo: UserAvatar {

    var visitBeaches: Int { get }
    var visitDivesites: Int { get }
    var visitGolfcourses: Int { get }
    var visitLocations: Int { get }
    var visitRestaurants: Int { get }
    var visitUncountries: Int { get }
    var visitWhss: Int { get }
}

struct UserJSON: Codable {

    enum Status: String {

        case active = "A"
        case deceased = "D"
        case inactive = "I"
        case notVerified = "W"
        case suspended = "S"
    }

    let airport: String?
    let bio: String?
    let birthday: Date
    let country: LocationJSON
    let countryId: Int
    let createdAt: Date
    let email: String
    let facebookEmail: String?
    let facebookId: Int?
    let facebookUserToken: String?
    // swiftlint:disable:next discouraged_optional_collection
    let favoritePlaces: [FavoritePlace]? // not in signup
    let firstName: String
    let fullName: String
    let gender: String
    let id: Int
    let lastLogIn: String?
    let lastName: String
    // swiftlint:disable:next discouraged_optional_collection
    let links: [Link]? // not in signup
    let location: LocationJSON
    let locationId: Int
    let picture: String?
    let rankBeaches: Int? // not in signup
    let rankDivesites: Int? // not in signup
    let rankGolfcourses: Int? // not in signup
    let rankLocations: Int? // not in signup
    let rankRestaurants: Int? // not in signup
    let rankUncountries: Int? // not in signup
    let rankWhss: Int? // not in signup
    let role: Int
    let score: Int? // not in signup
    let scoreBeaches: Int? // not in signup
    let scoreDivesites: Int? // not in signup
    let scoreGolfcourses: Int? // not in signup
    let scoreLocations: Int? // not in signup
    let scoreRestaurants: Int? // not in signup
    let scoreUncountries: Int? // not in signup
    let scoreWhss: Int? // not in signup
    let status: String
    let token: String? // found only in login + signup responses
    let updatedAt: Date
    let username: String
}

extension UserJSON: CustomStringConvertible {

    public var description: String {
        return "\(username) (\(id))"
    }
}

extension UserJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < User: \(description):
            airport: \(String(describing: airport))
            bio: \(String(describing: bio))
            birthday: \(birthday)
            country: \(country)
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
            location: \(location)
            links: \(links.debugDescription)
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
            score: \(String(describing: score))
            score_beaches: \(String(describing: scoreBeaches))
            score_divesites: \(String(describing: scoreDivesites))
            score_golfcourses: \(String(describing: scoreGolfcourses))
            score_locations: \(String(describing: scoreLocations))
            score_restaurants: \(String(describing: scoreRestaurants))
            score_uncountries: \(String(describing: scoreUncountries))
            score_whss: \(String(describing: scoreWhss))
            status: \(status)
            token: \(String(describing: token))
            updated_at: \(updatedAt)
            username: \(username)
        /User >
        """
    }
}

extension UserJSON: UserInfo {

    var visitBeaches: Int { return scoreBeaches ?? 0 }
    var visitDivesites: Int { return scoreDivesites ?? 0 }
    var visitGolfcourses: Int { return scoreGolfcourses ?? 0 }
    var visitLocations: Int { return scoreLocations ?? 0 }
    var visitRestaurants: Int { return scoreRestaurants ?? 0 }
    var visitUncountries: Int { return scoreUncountries ?? 0 }
    var visitWhss: Int { return scoreWhss ?? 0 }
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

extension UserAvatar {

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
}

@objcMembers final class User: Object, UserInfo {

    dynamic var fullName: String = ""
    dynamic var gender: String = ""
    dynamic var id: Int = 0
    dynamic var locationName: String = ""
    dynamic var picture: String?
    dynamic var visitBeaches: Int = 0
    dynamic var visitDivesites: Int = 0
    dynamic var visitGolfcourses: Int = 0
    dynamic var visitLocations: Int = 0
    dynamic var visitRestaurants: Int = 0
    dynamic var visitUncountries: Int = 0
    dynamic var visitWhss: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(from: RankedUserJSON,
                     with existing: User?) {
        self.init()

        fullName = from.fullName
        gender = from.gender
        id = from.id
        locationName = from.location.description
        picture = from.picture
        visitBeaches = from.scoreBeaches ?? existing?.visitBeaches ?? 0
        visitDivesites = from.scoreDivesites ?? existing?.visitDivesites ?? 0
        visitGolfcourses = from.scoreGolfcourses ?? existing?.visitGolfcourses ?? 0
        visitLocations = from.scoreLocations ?? existing?.visitLocations ?? 0
        visitRestaurants = from.scoreRestaurants ?? existing?.visitRestaurants ?? 0
        visitUncountries = from.scoreUncountries ?? existing?.visitUncountries ?? 0
        visitWhss = from.scoreWhss ?? existing?.visitWhss ?? 0
    }

    convenience init(from: UserJSON) {
        self.init()

        fullName = from.fullName
        gender = from.gender
        id = from.id
        locationName = from.location.description
        picture = from.picture
        visitBeaches = from.scoreBeaches ?? 0
        visitDivesites = from.scoreDivesites ?? 0
        visitGolfcourses = from.scoreGolfcourses ?? 0
        visitLocations = from.scoreLocations ?? 0
        visitRestaurants = from.scoreRestaurants ?? 0
        visitUncountries = from.scoreUncountries ?? 0
        visitWhss = from.scoreWhss ?? 0
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? User else { return false }
        guard !isSameObject(as: other) else { return true }
        return fullName == other.fullName &&
               gender == other.gender &&
               id == other.id &&
               locationName == other.locationName &&
               picture == other.picture &&
               visitBeaches == other.visitBeaches &&
               visitDivesites == other.visitDivesites &&
               visitGolfcourses == other.visitGolfcourses &&
               visitLocations == other.visitLocations &&
               visitRestaurants == other.visitRestaurants &&
               visitUncountries == other.visitUncountries &&
               visitWhss == other.visitWhss
    }
}
