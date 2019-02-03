// @copyright Trollwerks Inc.

import Nuke
import RealmSwift

struct UserJSON: Codable {

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

extension UserJSON {

    // swiftlint:disable:next closure_body_length
    static var loading: UserJSON = {
        UserJSON(
            airport: nil,
            bio: nil,
            birthday: Date(),
            country: LocationJSON.loading,
            countryId: 0,
            createdAt: Date(),
            email: "",
            facebookEmail: nil,
            facebookId: 0,
            facebookUserToken: nil,
            favoritePlaces: [],
            firstName: "",
            fullName: Localized.loading(),
            gender: "",
            id: 0,
            lastLogIn: nil,
            lastName: "",
            links: [],
            location: LocationJSON.loading,
            locationId: 0,
            picture: nil,
            rankBeaches: 0,
            rankDivesites: 0,
            rankGolfcourses: 0,
            rankLocations: 0,
            rankRestaurants: 0,
            rankUncountries: 0,
            rankWhss: 0,
            role: 0,
            score: 0,
            scoreBeaches: 0,
            scoreDivesites: 0,
            scoreGolfcourses: 0,
            scoreLocations: 0,
            scoreRestaurants: 0,
            scoreUncountries: 0,
            scoreWhss: 0,
            status: "",
            token: nil,
            updatedAt: Date(),
            username: ""
        )
    }()

    // swiftlint:disable:next function_body_length
    init(ranked: RankingsUser) {
        airport = nil
        bio = nil
        birthday = ranked.birthday
        country = ranked.country ?? ranked.location
        countryId = 0
        createdAt = Date()
        email = ""
        facebookEmail = nil
        facebookId = 0
        facebookUserToken = nil
        favoritePlaces = []
        firstName = ranked.firstName
        fullName = ranked.fullName
        gender = ranked.gender
        id = ranked.id
        lastLogIn = nil
        lastName = ranked.lastName
        location = ranked.location
        links = []
        locationId = ranked.locationId
        picture = nil
        rankBeaches = ranked.rankBeaches ?? 0
        rankDivesites = ranked.rankDivesites ?? 0
        rankGolfcourses = ranked.rankGolfcourses ?? 0
        rankLocations = ranked.rankLocations ?? 0
        rankRestaurants = ranked.rankRestaurants ?? 0
        rankUncountries = ranked.rankUncountries ?? 0
        rankWhss = ranked.rankWhss ?? 0
        role = ranked.role
        score = 0
        scoreBeaches = ranked.scoreBeaches ?? 0
        scoreDivesites = ranked.scoreDivesites ?? 0
        scoreGolfcourses = ranked.scoreGolfcourses ?? 0
        scoreLocations = ranked.scoreLocations ?? 0
        scoreRestaurants = ranked.scoreRestaurants ?? 0
        scoreUncountries = ranked.scoreUncountries ?? 0
        scoreWhss = ranked.scoreWhss ?? 0
        status = ""
        token = nil
        updatedAt = Date()
        username = ""
    }

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

    @discardableResult func set(thumbnail user: UserJSON) -> Bool {
        let placeholder = user.placeholder
        guard let url = user.imageUrl else {
            image = placeholder
            return true
        }

        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions(
                placeholder: placeholder,
                transition: .fadeIn(duration: 0.2)
            ),
            into: self
        )

        return false
    }
}

@objcMembers final class User: Object {

    dynamic var id: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(from: UserJSON) {
        self.init()
        
        id = from.id
   }
}
