// @copyright Trollwerks Inc.

import RealmSwift

// swiftlint:disable file_length

/// Abstraction for displaying avatars or placeholders
protocol UserAvatar {

    /// gender
    var gender: String? { get }
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
    /// orderHotels
    var orderHotels: Int { get }
    /// orderLocations
    var orderLocations: Int { get }
    /// orderRestaurants
    var orderRestaurants: Int { get }
    /// orderTop100Restaurants
    var orderTop100Restaurants: Int { get }
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
    /// visitHotels
    var visitHotels: Int { get }
    /// visitLocations
    var visitLocations: Int { get }
    /// visitRestaurants
    var visitRestaurants: Int { get }
    /// visitTop100Restaurants
    var visitTop100Restaurants: Int { get }
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
    let country: PlaceLocation?
    /// countryId
    let countryId: Int?
    /// createdAt
    let createdAt: Date?
    /// email
    let email: String?
    /// facebookEmail
    let facebookEmail: String?
    /// facebookId
    let facebookId: Int?
    /// facebookUserToken
    let facebookUserToken: String?
    /// firstName
    let firstName: String
    /// fullName
    let fullName: String?
    /// gender
    let gender: String?
    /// id
    let id: Int
    /// lastLogIn
    let lastLogIn: String?
    /// lastName
    let lastName: String
    /// links
    let links: [Link]?
    // swiftlint:disable:previous discouraged_optional_collection
    /// location
    let location: PlaceLocation?
    /// locationId
    let locationId: Int?
    /// picture
    let picture: String?
    /// rankBeaches
    let rankBeaches: Int?
    /// rankDivesites
    let rankDivesites: Int?
    /// rankGolfcourses
    let rankGolfcourses: Int?
    /// rankHotels
    let rankHotels: Int?
    /// rankLocations
    let rankLocations: Int?
    /// rankRestaurants
    let rankRestaurants: Int?
    /// rankTop100Restaurants
    let rankTop100Restaurants: Int?
    /// rankUncountries
    let rankUncountries: Int?
    /// rankWhss
    let rankWhss: Int?
    /// role
    let role: Int?
    /// score
    let score: Int?
    /// scoreBeaches
    let scoreBeaches: Int?
    /// scoreDivesites
    let scoreDivesites: Int?
    /// scoreGolfcourses
    let scoreGolfcourses: Int?
    /// scoreHotels
    let scoreHotels: Int?
    /// scoreLocations
    let scoreLocations: Int?
    /// scoreRestaurants
    let scoreRestaurants: Int?
    /// scoreTop100Restaurants
    let scoreTop100Restaurants: Int?
    /// scoreUncountries
    let scoreUncountries: Int?
    /// scoreWhss
    let scoreWhss: Int?
    /// status
    let status: String?
    /// token
    let token: String? // found only in login + signup responses
    /// updatedAt
    let updatedAt: Date?
    /// username
    let username: String?

    /// Convenience status accessor
    var isWaiting: Bool {
        if let status = status {
            return Status(rawValue: status) == .waiting
        }
        return false
    }

    /// Can rankings be displayed?
    var isComplete: Bool {
        birthday != nil &&
        country != nil &&
        location != nil &&
        gender != "U"
    }

    /// Copy and update visit counts
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
                        // favoritePlaces: favoritePlaces,
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
                        rankHotels: rankHotels,
                        rankLocations: rankLocations,
                        rankRestaurants: rankRestaurants,
                        rankTop100Restaurants: rankTop100Restaurants,
                        rankUncountries: rankUncountries,
                        rankWhss: rankWhss,
                        role: role,
                        score: score,
                        scoreBeaches: visited.beaches.count,
                        scoreDivesites: visited.divesites.count,
                        scoreGolfcourses: visited.golfcourses.count,
                        scoreHotels: visited.hotels?.count ?? 0,
                        scoreLocations: visited.locations.count,
                        scoreRestaurants: visited.restaurants.count,
                        scoreTop100Restaurants: visited.top100restaurants?.count ?? 0,
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
        "\(String(describing: username)) (\(id))"
    }
}

extension UserJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        """
        < User: \(description):
            airport: \(String(describing: airport))
            bio: \(String(describing: bio))
            birthday: \(String(describing: birthday))
            country: \(String(describing: country))
            country_id: \(String(describing: countryId))
            created_at: \(String(describing: createdAt))
            email: \(String(describing: email))
            facebook_email: \(String(describing: facebookEmail))
            facebook_id: \(String(describing: facebookId))
            facebook_user_token: \(String(describing: facebookUserToken))
            first_name: \(firstName)
            full_name: \(String(describing: fullName))
            gender: \(String(describing: gender))
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
            rankHotels: \(String(describing: rankHotels))
            rankLocations: \(String(describing: rankLocations))
            rankRestaurants: \(String(describing: rankRestaurants))
            rankUncountries: \(String(describing: rankUncountries))
            rankWhss: \(String(describing: rankWhss))
            role: \(String(describing: role))
            score: \(String(describing: score))
            score_beaches: \(String(describing: scoreBeaches))
            score_divesites: \(String(describing: scoreDivesites))
            score_golfcourses: \(String(describing: scoreGolfcourses))
            score_hotels: \(String(describing: scoreHotels))
            score_locations: \(String(describing: scoreLocations))
            score_restaurants: \(String(describing: scoreRestaurants))
            score_uncountries: \(String(describing: scoreUncountries))
            score_whss: \(String(describing: scoreWhss))
            status: \(String(describing: status))
            token: \(String(describing: token))
            updated_at: \(String(describing: updatedAt))
            username: \(String(describing: username))
        /User >
        """
    }
}

extension UserJSON: UserInfo {

    var isSelf: Bool {
        id == data.user?.id
    }
    var orderBeaches: Int { rankBeaches ?? 0 }
    var orderDivesites: Int { rankDivesites ?? 0 }
    var orderGolfcourses: Int { rankGolfcourses ?? 0 }
    var orderHotels: Int { rankHotels ?? 0 }
    var orderLocations: Int { rankLocations ?? 0 }
    var orderRestaurants: Int { rankRestaurants ?? 0 }
    var orderTop100Restaurants: Int { rankTop100Restaurants ?? 0 }
    var orderUncountries: Int { rankUncountries ?? 0 }
    var orderWhss: Int { rankWhss ?? 0 }
    var visitBeaches: Int { scoreBeaches ?? 0 }
    var visitDivesites: Int { scoreDivesites ?? 0 }
    var visitGolfcourses: Int { scoreGolfcourses ?? 0 }
    var visitHotels: Int { scoreHotels ?? 0 }
    var visitLocations: Int { scoreLocations ?? 0 }
    var visitRestaurants: Int { scoreRestaurants ?? 0 }
    var visitTop100Restaurants: Int { scoreTop100Restaurants ?? 0 }
    var visitUncountries: Int { scoreUncountries ?? 0 }
    var visitWhss: Int { scoreWhss ?? 0 }
}

/// Apparently unimplemented so far
struct FavoritePlace: Codable, Hashable, CustomStringConvertible, CustomDebugStringConvertible {

    private let id: String?
    private let type: String?

    var description: String {
        debugDescription
    }

    var debugDescription: String {
        """
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
        text.isEmpty && url.isEmpty
    }

    /// Initialize by injection
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
        debugDescription
    }

    var debugDescription: String {
        "< Link: text \(text) url \(url)>"
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
    dynamic var gender: String?
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
    /// orderHotels
    dynamic var orderHotels: Int = 0
    /// orderLocations
    dynamic var orderLocations: Int = 0
    /// orderRestaurants
    dynamic var orderRestaurants: Int = 0
    /// orderTop100Restaurants
    dynamic var orderTop100Restaurants: Int = 0
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
    /// visitHotels
    dynamic var visitHotels: Int = 0
    /// visitLocations
    dynamic var visitLocations: Int = 0
    /// visitRestaurants
    dynamic var visitRestaurants: Int = 0
    /// visitTop100Restaurants
    dynamic var visitTop100Restaurants: Int = 0
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
        userId == data.user?.id
    }

    /// :nodoc:
    override static func primaryKey() -> String? {
        "userId"
    }

    /// Constructor from MTP endpoint data
    convenience init(from: UserJSON) {
        self.init()

        airport = from.airport ?? ""
        bio = from.bio ?? ""
        fullName = from.fullName ?? "\(from.firstName) \(from.lastName)"
        gender = from.gender
        userId = from.id
        locationName = from.location?.description ?? ""
        picture = from.picture
        orderBeaches = from.rankBeaches ?? 0
        orderDivesites = from.rankDivesites ?? 0
        orderGolfcourses = from.rankGolfcourses ?? 0
        orderHotels = from.rankHotels ?? 0
        orderLocations = from.rankLocations ?? 0
        orderRestaurants = from.rankRestaurants ?? 0
        orderUncountries = from.rankUncountries ?? 0
        orderWhss = from.rankWhss ?? 0
        visitBeaches = from.scoreBeaches ?? 0
        visitDivesites = from.scoreDivesites ?? 0
        visitGolfcourses = from.scoreGolfcourses ?? 0
        visitHotels = from.scoreHotels ?? 0
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
               visitHotels == other.visitHotels &&
               visitLocations == other.visitLocations &&
               visitRestaurants == other.visitRestaurants &&
               visitUncountries == other.visitUncountries &&
               visitWhss == other.visitWhss &&
               linkTexts == other.linkTexts &&
               linkUrls == other.linkUrls
    }
}
