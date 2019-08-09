// @copyright Trollwerks Inc.

import RealmSwift

// swiftlint:disable file_length

/// Abstraction for displaying avatars or placeholders
protocol UserAvatar {

    /// gender
    var gender: String { get }
    /// picture
    var picture: String? { get }
}

/// Abstraction for logged in or other users
protocol UserInfo: UserAvatar {

    /// Is this logged in user?
    var isSelf: Bool { get }
    /// orderBeaches
    var orderBeaches: Int { get }
    /// orderDivesites
    var orderDivesites: Int { get }
    /// orderGolfcourses
    var orderGolfcourses: Int { get }
    /// orderLocations
    var orderLocations: Int { get }
    /// orderRestaurants
    var orderRestaurants: Int { get }
    /// orderUncountries
    var orderUncountries: Int { get }
    /// orderWhss
    var orderWhss: Int { get }
    /// visitBeaches
    var visitBeaches: Int { get }
    /// visitDivesites
    var visitDivesites: Int { get }
    /// visitGolfcourses
    var visitGolfcourses: Int { get }
    /// visitLocations
    var visitLocations: Int { get }
    /// visitRestaurants
    var visitRestaurants: Int { get }
    /// visitUncountries
    var visitUncountries: Int { get }
    /// visitWhss
    var visitWhss: Int { get }
}

/// Reply from user information endpoints
struct UserJSON: Codable, Equatable, ServiceProvider {

    private enum Status: String {

        case active = "A"
        case deceased = "D"
        case inactive = "I"
        case suspended = "S"
        case waiting = "W"
    }

    /// airport
    let airport: String?
    /// bio
    let bio: String?
    /// birthday
    let birthday: Date?
    /// country
    let country: LocationJSON?
    /// countryId
    let countryId: Int?
    /// createdAt
    let createdAt: Date
    /// email
    let email: String
    /// facebookEmail
    let facebookEmail: String?
    /// facebookId
    let facebookId: Int?
    /// facebookUserToken
    let facebookUserToken: String?
    /// firstName
    let firstName: String
    /// fullName
    let fullName: String
    /// gender
    let gender: String
    /// id
    let id: Int
    /// lastLogIn
    let lastLogIn: String?
    /// lastName
    let lastName: String
    /// links
    let links: [Link]? // not in signup
    // swiftlint:disable:previous discouraged_optional_collection
    /// location
    let location: LocationJSON?
    /// locationId
    let locationId: Int?
    /// picture
    let picture: String?
    /// rankBeaches
    let rankBeaches: Int? // not in signup
    /// rankDivesites
    let rankDivesites: Int? // not in signup
    /// rankGolfcourses
    let rankGolfcourses: Int? // not in signup
    /// rankLocations
    let rankLocations: Int? // not in signup
    /// rankRestaurants
    let rankRestaurants: Int? // not in signup
    /// rankUncountries
    let rankUncountries: Int? // not in signup
    /// rankWhss
    let rankWhss: Int? // not in signup
    /// role
    let role: Int
    /// score
    let score: Int? // not in signup
    /// scoreBeaches
    let scoreBeaches: Int? // not in signup
    /// scoreDivesites
    let scoreDivesites: Int? // not in signup
    /// scoreGolfcourses
    let scoreGolfcourses: Int? // not in signup
    /// scoreLocations
    let scoreLocations: Int? // not in signup
    /// scoreRestaurants
    let scoreRestaurants: Int? // not in signup
    /// scoreUncountries
    let scoreUncountries: Int? // not in signup
    /// scoreWhss
    let scoreWhss: Int? // not in signup
    /// status
    let status: String
    /// token
    let token: String? // found only in login + signup responses
    /// updatedAt
    let updatedAt: Date
    /// username
    let username: String

    /// Convenience status accessor
    var isWaiting: Bool {
        return Status(rawValue: status) == .waiting
    }

    /// Can rankings be displayed?
    var isComplete: Bool {
        return birthday != nil &&
               country != nil &&
               location != nil &&
               gender != "U"
    }

    /// Copy and update visit counts
    ///
    /// - Parameter visited: New visit counts
    /// - Returns: Copy with visited applied
    func updated(visited: Checked) -> UserJSON {
        // swiftlint:disable:previous function_body_length
        let whsScore = visited.whss.reduce(0) {
            let hasParent = data.get(whs: $1)?.hasParent ?? false
            return $0 + (hasParent ? 0 : 1)
        }

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
                        scoreWhss: whsScore,
                        status: status,
                        token: token,
                        updatedAt: updatedAt,
                        username: username)
    }
}

extension UserJSON: CustomStringConvertible {

    var description: String {
        return "\(username) (\(id))"
    }
}

extension UserJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < User: \(description):
            airport: \(String(describing: airport))
            bio: \(String(describing: bio))
            birthday: \(String(describing: birthday))
            country: \(String(describing: country))
            country_id: \(String(describing: countryId))
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
            location: \(String(describing: location))
            links: \(links.debugDescription)
            location_id: \(String(describing: locationId))
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

    var isSelf: Bool {
        return id == data.user?.id
    }
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

/// Apparently unimplemented so far
struct FavoritePlace: Codable, Hashable, CustomStringConvertible, CustomDebugStringConvertible {

    private let id: String?
    private let type: String?

    var description: String {
        return debugDescription
    }

    var debugDescription: String {
        return """
        < Favorite Place:
            id \(String(describing: id))
            type \(String(describing: type))>
        """
    }
}

/// Links to display in user profile
struct Link: Codable, Hashable {

    /// text
    let text: String
    /// url
    let url: String

    /// Convience isEmpty accessor
    var isEmpty: Bool {
        return text.isEmpty && url.isEmpty
    }

    /// Initialize by injection
    ///
    /// - Parameters:
    ///   - text: text
    ///   - url: url
    init(text: String = "",
         url: String = "") {
        self.text = text
        self.url = url
    }
}

extension Link: CustomStringConvertible, CustomDebugStringConvertible {

    var description: String {
        return debugDescription
    }

    var debugDescription: String {
        return "< Link: text \(text) url \(url)>"
    }
}

extension UserAvatar {

    /// imageUrl
    var imageUrl: URL? {
        guard let uuid = picture, !uuid.isEmpty else { return nil }
        let target = MTP.picture(uuid: uuid, size: .thumb)
        return target.requestUrl
    }

    /// placeholder
    var placeholder: UIImage? {
        switch gender {
        case "F":
            return R.image.placeholderFemaleThumb()
        case "M", "U":
            return R.image.placeholderMaleThumb()
        default:
            return R.image.placeholderThumb()
        }
    }
}

/// Realm representation of a MTP user
@objcMembers final class User: Object, UserInfo, ServiceProvider {

    /// airport
    dynamic var airport: String = ""
    /// bio
    dynamic var bio: String = ""
    /// fullName
    dynamic var fullName: String = ""
    /// gender
    dynamic var gender: String = ""
    /// locationName
    dynamic var locationName: String = ""
    /// picture
    dynamic var picture: String?
    /// orderBeaches
    dynamic var orderBeaches: Int = 0
    /// orderDivesites
    dynamic var orderDivesites: Int = 0
    /// orderGolfcourses
    dynamic var orderGolfcourses: Int = 0
    /// orderLocations
    dynamic var orderLocations: Int = 0
    /// orderRestaurants
    dynamic var orderRestaurants: Int = 0
    /// orderUncountries
    dynamic var orderUncountries: Int = 0
    /// orderWhss
    dynamic var orderWhss: Int = 0
    /// userId
    dynamic var userId: Int = 0
    /// visitBeaches
    dynamic var visitBeaches: Int = 0
    /// visitDivesites
    dynamic var visitDivesites: Int = 0
    /// visitGolfcourses
    dynamic var visitGolfcourses: Int = 0
    /// visitLocations
    dynamic var visitLocations: Int = 0
    /// visitRestaurants
    dynamic var visitRestaurants: Int = 0
    /// visitUncountries
    dynamic var visitUncountries: Int = 0
    /// visitWhss
    dynamic var visitWhss: Int = 0

    /// linkTexts
    let linkTexts = List<String>()
    /// linkUrls
    let linkUrls = List<String>()

    /// Is this logged in user?
    var isSelf: Bool {
        return userId == data.user?.id
    }

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "userId"
    }

    /// Constructor from MTP endpoint data
    convenience init(from: UserJSON) {
        self.init()

        airport = from.airport ?? ""
        bio = from.bio ?? ""
        fullName = from.fullName
        gender = from.gender
        userId = from.id
        locationName = from.location?.description ?? ""
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

    /// Constructor from MTP endpoint data
    convenience init(from: SearchResultItemJSON) {
        self.init()

        fullName = from.label
        userId = from.id
    }

    /// Constructor from MTP endpoint data
    convenience init?(from: OwnerJSON,
                      with existing: User?) {
        guard existing == nil else { return nil }

        self.init()

        fullName = from.fullName
        userId = from.id
    }

    /// Equality operator
    ///
    /// - Parameter object: Other object
    /// - Returns: equality
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? User else { return false }
        guard !isSameObject(as: other) else { return true }
        return airport == other.airport &&
               bio == other.bio &&
               fullName == other.fullName &&
               gender == other.gender &&
               locationName == other.locationName &&
               picture == other.picture &&
               userId == other.userId &&
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
