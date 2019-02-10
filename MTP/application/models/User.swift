// @copyright Trollwerks Inc.

import Nuke
import RealmSwift

protocol UserInfo {

    var gender: String { get }
    var picture: String? { get }
    var scoreBeaches: Int { get }
    var scoreDivesites: Int { get }
    var scoreGolfcourses: Int { get }
    var scoreLocations: Int { get }
    var scoreRestaurants: Int { get }
    var scoreUncountries: Int { get }
    var scoreWhss: Int { get }
}

struct UserJSON: Codable, UserInfo {

    let airport: String?
    let bio: String?
    let birthday: Date
    let country: LocationJSON // still has 30 items
    let countryId: Int
    let createdAt: Date
    let email: String
    let facebookEmail: String?
    let facebookId: Int?
    let facebookUserToken: String?
    let favoritePlaces: [FavoritePlace]
    let firstName: String
    let fullName: String
    let gender: String
    let id: Int
    let lastLogIn: String?
    let lastName: String
    let links: [Link]
    let location: LocationJSON // still has 30 items
    let locationId: Int
    let picture: String?
    let rankBeaches: Int
    let rankDivesites: Int
    let rankGolfcourses: Int
    let rankLocations: Int
    let rankRestaurants: Int
    let rankUncountries: Int
    let rankWhss: Int
    let role: Int
    let score: Int
    let scoreBeaches: Int
    let scoreDivesites: Int
    let scoreGolfcourses: Int
    let scoreLocations: Int
    let scoreRestaurants: Int
    let scoreUncountries: Int
    let scoreWhss: Int
    let status: String
    let token: String? // found only in login response
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

extension UserInfo {

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

extension UIImageView {

    func set(thumbnail user: UserInfo) {
        let placeholder = user.placeholder
        guard let url = user.imageUrl else {
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

@objcMembers final class User: Object, UserInfo {

    dynamic var fullName: String = ""
    dynamic var gender: String = ""
    dynamic var id: Int = 0
    dynamic var locationName: String = ""
    dynamic var picture: String?
    dynamic var scoreBeaches: Int = 0
    dynamic var scoreDivesites: Int = 0
    dynamic var scoreGolfcourses: Int = 0
    dynamic var scoreLocations: Int = 0
    dynamic var scoreRestaurants: Int = 0
    dynamic var scoreUncountries: Int = 0
    dynamic var scoreWhss: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(from: RankedUserJSON) {
        self.init()

        fullName = from.fullName
        gender = from.gender
        id = from.id
        locationName = from.location.description
        picture = from.picture
        scoreBeaches = from.scoreBeaches ?? 0
        scoreDivesites = from.scoreDivesites ?? 0
        scoreGolfcourses = from.scoreGolfcourses ?? 0
        scoreLocations = from.scoreLocations ?? 0
        scoreRestaurants = from.scoreRestaurants ?? 0
        scoreUncountries = from.scoreUncountries ?? 0
        scoreWhss = from.scoreWhss ?? 0
   }

    convenience init(from: UserJSON) {
        self.init()

        fullName = from.fullName
        gender = from.gender
        id = from.id
        locationName = from.location.description
        picture = from.picture
        scoreBeaches = from.scoreBeaches
        scoreDivesites = from.scoreDivesites
        scoreGolfcourses = from.scoreGolfcourses
        scoreLocations = from.scoreLocations
        scoreRestaurants = from.scoreRestaurants
        scoreUncountries = from.scoreUncountries
        scoreWhss = from.scoreWhss
    }
}
