// @copyright Trollwerks Inc.

import RealmSwift

protocol UserAvatar {

    var gender: String { get }
    var picture: String? { get }
}

protocol UserInfo: UserAvatar {

    var orderBeaches: Int { get }
    var orderDivesites: Int { get }
    var orderGolfcourses: Int { get }
    var orderLocations: Int { get }
    var orderRestaurants: Int { get }
    var orderUncountries: Int { get }
    var orderWhss: Int { get }
    var visitBeaches: Int { get }
    var visitDivesites: Int { get }
    var visitGolfcourses: Int { get }
    var visitLocations: Int { get }
    var visitRestaurants: Int { get }
    var visitUncountries: Int { get }
    var visitWhss: Int { get }
}

struct UserJSON: Codable, Equatable {

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
    //let favoritePlaces: [FavoritePlace]? // not in signup
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

    func updated(visited: Checked) -> UserJSON {
        return UserJSON(airport: airport,
                        bio: bio,
                        birthday: birthday,
                        country: country,
                        countryId: countryId,
                        createdAt: createdAt,
                        email: email,
                        facebookEmail: facebookEmail,
                        facebookId: facebookId,
                        facebookUserToken: facebookUserToken,
                        //favoritePlaces: favoritePlaces,
                        firstName: firstName,
                        fullName: fullName,
                        gender: gender,
                        id: id,
                        lastLogIn: lastLogIn,
                        lastName: lastName,
                        links: links,
                        location: location,
                        locationId: locationId,
                        picture: picture,
                        rankBeaches: rankBeaches,
                        rankDivesites: rankDivesites,
                        rankGolfcourses: rankGolfcourses,
                        rankLocations: rankLocations,
                        rankRestaurants: rankRestaurants,
                        rankUncountries: rankUncountries,
                        rankWhss: rankWhss,
                        role: role,
                        score: score,
                        scoreBeaches: visited.beaches.count,
                        scoreDivesites: visited.divesites.count,
                        scoreGolfcourses: visited.golfcourses.count,
                        scoreLocations: visited.locations.count,
                        scoreRestaurants: visited.restaurants.count,
                        scoreUncountries: visited.uncountries.count,
                        scoreWhss: visited.whss.count,
                        status: status,
                        token: token,
                        updatedAt: updatedAt,
                        username: username)
    }
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

    var orderBeaches: Int { return rankBeaches ?? 0 }
    var orderDivesites: Int { return rankDivesites ?? 0 }
    var orderGolfcourses: Int { return rankGolfcourses ?? 0 }
    var orderLocations: Int { return rankLocations ?? 0 }
    var orderRestaurants: Int { return rankRestaurants ?? 0 }
    var orderUncountries: Int { return rankUncountries ?? 0 }
    var orderWhss: Int { return rankWhss ?? 0 }
    var visitBeaches: Int { return scoreBeaches ?? 0 }
    var visitDivesites: Int { return scoreDivesites ?? 0 }
    var visitGolfcourses: Int { return scoreGolfcourses ?? 0 }
    var visitLocations: Int { return scoreLocations ?? 0 }
    var visitRestaurants: Int { return scoreRestaurants ?? 0 }
    var visitUncountries: Int { return scoreUncountries ?? 0 }
    var visitWhss: Int { return scoreWhss ?? 0 }
}

struct FavoritePlace: Codable, Hashable {

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

struct Link: Codable, Hashable {

    let text: String
    let url: String

    var isEmpty: Bool {
        return text.isEmpty && url.isEmpty
    }

    init(text: String = "",
         url: String = "") {
        self.text = text
        self.url = url
    }
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
        let target = MTP.picture(uuid: uuid, size: .thumb)
        return target.requestUrl
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

    dynamic var airport: String = ""
    dynamic var bio: String = ""
    dynamic var fullName: String = ""
    dynamic var gender: String = ""
    dynamic var id: Int = 0
    dynamic var locationName: String = ""
    dynamic var picture: String?
    dynamic var orderBeaches: Int = 0
    dynamic var orderDivesites: Int = 0
    dynamic var orderGolfcourses: Int = 0
    dynamic var orderLocations: Int = 0
    dynamic var orderRestaurants: Int = 0
    dynamic var orderUncountries: Int = 0
    dynamic var orderWhss: Int = 0
    dynamic var visitBeaches: Int = 0
    dynamic var visitDivesites: Int = 0
    dynamic var visitGolfcourses: Int = 0
    dynamic var visitLocations: Int = 0
    dynamic var visitRestaurants: Int = 0
    dynamic var visitUncountries: Int = 0
    dynamic var visitWhss: Int = 0

    let linkTexts = List<String>()
    let linkUrls = List<String>()

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(from: RankedUserJSON,
                     with existing: User?) {
        self.init()

        airport = existing?.airport ?? ""
        bio = existing?.bio ?? ""
        fullName = from.fullName
        gender = from.gender
        id = from.id
        locationName = from.location.description
        picture = from.picture
        orderBeaches = from.rankBeaches ?? existing?.orderBeaches ?? 0
        orderDivesites = from.rankDivesites ?? existing?.orderDivesites ?? 0
        orderGolfcourses = from.rankGolfcourses ?? existing?.orderGolfcourses ?? 0
        orderLocations = from.rankLocations ?? existing?.orderLocations ?? 0
        orderRestaurants = from.rankRestaurants ?? existing?.orderRestaurants ?? 0
        orderUncountries = from.rankUncountries ?? existing?.orderUncountries ?? 0
        orderWhss = from.rankWhss ?? existing?.orderWhss ?? 0
        visitBeaches = from.scoreBeaches ?? existing?.visitBeaches ?? 0
        visitDivesites = from.scoreDivesites ?? existing?.visitDivesites ?? 0
        visitGolfcourses = from.scoreGolfcourses ?? existing?.visitGolfcourses ?? 0
        visitLocations = from.scoreLocations ?? existing?.visitLocations ?? 0
        visitRestaurants = from.scoreRestaurants ?? existing?.visitRestaurants ?? 0
        visitUncountries = from.scoreUncountries ?? existing?.visitUncountries ?? 0
        visitWhss = from.scoreWhss ?? existing?.visitWhss ?? 0

        existing?.linkTexts.forEach { linkTexts.append($0) }
        existing?.linkUrls.forEach { linkUrls.append($0) }
    }

    convenience init(from: UserJSON) {
        self.init()

        airport = from.airport ?? ""
        bio = from.bio ?? ""
        fullName = from.fullName
        gender = from.gender
        id = from.id
        locationName = from.location.description
        picture = from.picture
        orderBeaches = from.rankBeaches ?? 0
        orderDivesites = from.rankDivesites ?? 0
        orderGolfcourses = from.rankGolfcourses ?? 0
        orderLocations = from.rankLocations ?? 0
        orderRestaurants = from.rankRestaurants ?? 0
        orderUncountries = from.rankUncountries ?? 0
        orderWhss = from.rankWhss ?? 0
        visitBeaches = from.scoreBeaches ?? 0
        visitDivesites = from.scoreDivesites ?? 0
        visitGolfcourses = from.scoreGolfcourses ?? 0
        visitLocations = from.scoreLocations ?? 0
        visitRestaurants = from.scoreRestaurants ?? 0
        visitUncountries = from.scoreUncountries ?? 0
        visitWhss = from.scoreWhss ?? 0

        from.links?.forEach {
            linkTexts.append($0.text)
            linkUrls.append($0.url)
        }
    }

    convenience init(from: SearchResultItemJSON) {
        self.init()

        fullName = from.label
        id = from.id
   }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? User else { return false }
        guard !isSameObject(as: other) else { return true }
        return airport == other.airport &&
               bio == other.bio &&
               fullName == other.fullName &&
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
               visitWhss == other.visitWhss &&
               linkTexts == other.linkTexts &&
               linkUrls == other.linkUrls
    }
}
