// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

// swiftlint:disable file_length

/// Tracks place types to show on map
struct ChecklistFlags: Codable, Equatable {

    /// number types that are mappable
    static let mappableCount = 7

    /// Whether to show beaches
    var beaches: Bool = true
    /// Whether to show divesites
    var divesites: Bool = true
    /// Whether to show golfcourses
    var golfcourses: Bool = true
    /// Whether to show hotels
    var hotels: Bool = true
    /// Whether to show locations
    var locations: Bool = true
    /// Whether to show restaurants
    var restaurants: Bool = true
    /// Whether to show uncountries
    var uncountries: Bool = true
    /// Whether to show whss
    var whss: Bool = true

    /// Default constructor
    /// - Parameter flagged: Default on or off
    init(flagged: Bool = true) {
        beaches = flagged
        divesites = flagged
        golfcourses = flagged
        hotels = flagged
        locations = flagged
        restaurants = flagged
        uncountries = flagged
        whss = flagged
    }

    /// Whether a particular list type is shown
    /// - Parameter list: The list type
    /// - Returns: Whether shown
    func display(list: Checklist) -> Bool {
        switch list {
        case .beaches: return beaches
        case .divesites: return divesites
        case .golfcourses: return golfcourses
        case .hotels: return hotels
        case .locations: return locations
        case .restaurants: return restaurants
        case .uncountries: return uncountries
        case .whss: return whss
        }
    }
}

/// The list types to track visits to
enum Checklist: Int, CaseIterable, ServiceProvider {
    // swiftlint:disable:previous type_body_length

    /// MTP Locations
    case locations
    /// UN Countries
    case uncountries
    /// World Heritage Sites
    case whss
    /// Beaches
    case beaches
    /// Golf courses
    case golfcourses
    /// Dive sites
    case divesites
    /// Restaurants
    case restaurants
    /// Top Hotels
    case hotels

    /// Individual item identifier
    typealias Item = (list: Checklist, id: Int)
    /// Current count of visits
    typealias VisitStatus = (visited: Int, remaining: Int)

    /// Constructor from text key found in JSON
    init?(key: String) {
        switch key {
        case "locations": self = .locations
        case "uncountries": self = .uncountries
        case "whss": self = .whss
        case "beaches": self = .beaches
        case "golfcourses": self = .golfcourses
        case "divesites": self = .divesites
        case "restaurants": self = .restaurants
        case "hotels": self = .hotels
        default: return nil
        }
    }

    /// Mapper to JSON text key
    var key: String {
        switch self {
        case .locations: return "locations"
        case .uncountries: return "uncountries"
        case .whss: return "whss"
        case .beaches: return "beaches"
        case .golfcourses: return "golfcourses"
        case .divesites: return "divesites"
        case .restaurants: return "restaurants"
        case .hotels: return "hotels"
        }
    }

    /// Background color for map markers
    var marker: UIColor {
        let marker: UIColor?
        switch self {
        case .locations:
            marker = R.color.locations()
        case .uncountries:
            marker = R.color.uncountries()
        case .whss:
            marker = R.color.whss()
        case .beaches:
            marker = R.color.beaches()
        case .golfcourses:
            marker = R.color.golfcourses()
        case .divesites:
            marker = R.color.divesites()
        case .restaurants:
            marker = R.color.restaurants()
        case .hotels:
            marker = R.color.hotels()
        }
        // swiftlint:disable:next force_unwrapping
        return marker!
    }

    /// Image for map markers
    var image: UIImage {
        let image: UIImage?
        switch self {
        case .locations:
            image = R.image.listMTP()
        case .uncountries:
            image = R.image.listUN()
        case .whss:
            image = R.image.listWHS()
        case .beaches:
            image = R.image.listBeaches()
        case .golfcourses:
            image = R.image.listGolf()
        case .divesites:
            image = R.image.listDive()
        case .restaurants:
            image = R.image.listRestaurants()
        case .hotels:
            image = R.image.listHotels()
        }
        // swiftlint:disable:next force_unwrapping
        return image!
    }

    /// Accessor for laying out Counts pages
    func hasChildren(id: Int) -> Bool {
        switch self {
        case .whss:
            return data.hasChildren(whs: id)
        default:
            return false
        }
    }

    /// Accessor for determining parent visited status
    func hasVisitedChildren(id: Int) -> Bool {
        switch self {
        case .whss:
            return !data.visitedChildren(whs: id).isEmpty
        default:
            return false
        }
    }

    /// Accessor for determining child status
    func hasParent(id: Int) -> Bool {
        switch self {
        case .whss:
            return data.get(whs: id)?.hasParent ?? false
        default:
            return false
        }
    }

    /// Accessor for previously dismissed notifications
    func isDismissed(id: Int) -> Bool {
        let item = (list: self, id: id)
        return data.dismissed?.isStamped(item: item) ?? false
    }

    /// Accessor for presented notifications
    func isNotified(id: Int) -> Bool {
        let item = (list: self, id: id)
        return data.notified?.isStamped(item: item) ?? false
    }

    /// Accessor for pending notifications
    func isTriggered(id: Int) -> Bool {
        let item = (list: self, id: id)
        return data.triggered?.isStamped(item: item) ?? false
    }

    /// Accessor for visited status
    func isVisited(id: Int) -> Bool {
        return visited.contains(id)
    }

    /// Mapper to PlaceInfo interface
    func place(id: Int) -> PlaceInfo? {
        return places.first { $0.placeId == id }
    }

    /// All places of this type
    var places: [PlaceInfo] {
        let places: [PlaceInfo]
        switch self {
        case .locations:
            places = data.locations
        case .uncountries:
            places = data.uncountries
        case .whss:
            places = data.whss
        case .beaches:
            places = data.beaches
        case .golfcourses:
            places = data.golfcourses
        case .divesites:
            places = data.divesites
        case .restaurants:
            places = data.restaurants
        case .hotels:
            places = data.hotels
        }
        return places
    }

    /// Set dismissed status
    func set(dismissed: Bool, id: Int) {
        let item = (list: self, id: id)
        var timestamps = data.dismissed ?? Timestamps()
        timestamps.set(item: item, stamped: dismissed)
        data.dismissed = timestamps
        if dismissed {
            set(triggered: false, id: id)
        }
    }

    /// Set notified status
    func set(notified: Bool, id: Int) {
        let item = (list: self, id: id)
        var timestamps = data.notified ?? Timestamps()
        timestamps.set(item: item, stamped: notified)
        data.notified = timestamps
    }

    /// Set triggered status
    func set(triggered: Bool, id: Int) {
        let item = (list: self, id: id)
        var timestamps = data.triggered ?? Timestamps()
        timestamps.set(item: item, stamped: triggered)
        data.triggered = timestamps
    }

    /// Determine items to sync with website
    func changes(id: Int,
                 visited: Bool) -> [Item] {
        guard self != .uncountries,
              isVisited(id: id) != visited else { return [] }

        switch self {
        case .uncountries:
            return []
        case .whss:
            if let parent = data.get(whs: id)?.parent {
                let visitedChildren = data.visitedChildren(whs: parent.placeId)
                let otherVisits: Bool
                if visitedChildren.count == 1,
                   visitedChildren[0].placeId == id {
                    otherVisits = false
                } else {
                    otherVisits = !visitedChildren.isEmpty
                }
                switch (visited, otherVisits) {
                case (true, false),
                     (false, false) where parent.visited:
                    return [(self, id), (self, parent.placeId)]
                default:
                    break
                }
            }
        case .beaches,
             .divesites,
             .golfcourses,
             .hotels,
             .locations,
             .restaurants:
            break
        }
        return [(self, id)]
    }

    /// Accessor for logged in user rank
    func rank(of user: UserJSON? = nil) -> Int {
        guard let user = user ?? data.user else { return 0 }

        switch self {
        case .locations:
            return user.rankLocations ?? 0
        case .uncountries:
            return user.rankUncountries ?? 0
        case .whss:
            return user.rankWhss ?? 0
        case .beaches:
            return user.rankBeaches ?? 0
        case .golfcourses:
            return user.rankGolfcourses ?? 0
        case .divesites:
            return user.rankDivesites ?? 0
        case .restaurants:
            return user.rankRestaurants ?? 0
        case .hotels:
            return user.rankHotels ?? 0
        }
    }

    /// Accessor for other user rank
    func rank(of user: User) -> Int {
        switch self {
        case .locations:
            return user.orderLocations
        case .uncountries:
            return user.orderUncountries
        case .whss:
            return user.orderWhss
        case .beaches:
            return user.orderBeaches
        case .golfcourses:
            return user.orderGolfcourses
        case .divesites:
            return user.orderDivesites
        case .restaurants:
            return user.orderRestaurants
        case .hotels:
            return user.orderHotels
        }
    }

    /// Accessor for remaining count
    func remaining(of user: UserInfo) -> Int {
        return visitStatus(of: user).remaining
    }

    /// Accessor for visited/remaining counts
    func visitStatus(of user: UserInfo) -> VisitStatus {
        let total: Int
        switch self {
        case .locations:
            total = data.locations.filter { $0.placeId > 0 }.count
        case .uncountries:
            total = data.uncountries.count
        case .whss:
            total = data.whss.filter { !$0.hasParent }.count
        case .beaches:
            total = data.beaches.count
        case .golfcourses:
            total = data.golfcourses.count
        case .divesites:
            total = data.divesites.count
        case .restaurants:
            total = data.restaurants.count
        case .hotels:
            total = data.hotels.count
        }
        let complete = visits(of: user)
        return (complete, total - complete)
    }

    /// Title to display in UI
    var title: String {
        switch self {
        case .locations:
            return L.locations()
        case .uncountries:
            return L.uncountries()
        case .whss:
            return L.whss()
        case .beaches:
            return L.beaches()
        case .golfcourses:
            return L.golfcourses()
        case .divesites:
            return L.divesites()
        case .restaurants:
            return L.restaurants()
        case .hotels:
            return L.hotels()
        }
    }

    /// Accessor for category description
    func category(full: Bool) -> String {
        switch self {
        case .locations:
            return L.location()
        case .uncountries:
            return L.uncountry()
        case .whss:
            return full ? L.whsFull() : L.whsShort()
        case .beaches:
            return L.beach()
        case .golfcourses:
            return L.golfcourse()
        case .divesites:
            return L.divesite()
        case .restaurants:
            return L.restaurant()
        case .hotels:
            return L.hotel()
        }
    }

    /// Accessor for visit count
    func visits(of user: UserInfo) -> Int {
        switch self {
        case .locations:
            return user.visitLocations
        case .uncountries:
            return user.visitUncountries
        case .whss:
            return user.visitWhss
        case .beaches:
            return user.visitBeaches
        case .golfcourses:
            return user.visitGolfcourses
        case .divesites:
            return user.visitDivesites
        case .restaurants:
            return user.visitRestaurants
        case .hotels:
            return user.visitHotels
        }
    }

    /// Accessor for order of user
    func order(of user: UserInfo) -> Int {
        switch self {
        case .locations:
            return user.orderLocations
        case .uncountries:
            return user.orderUncountries
        case .whss:
            return user.orderWhss
        case .beaches:
            return user.orderBeaches
        case .golfcourses:
            return user.orderGolfcourses
        case .divesites:
            return user.orderDivesites
        case .restaurants:
            return user.orderRestaurants
        case .hotels:
            return user.orderHotels
        }
    }

    /// Accessor for complete visit list
    var visited: [Int] {
        guard let visited = data.visited else { return [] }

        switch self {
        case .locations:
            return visited.locations
        case .uncountries:
            return visited.uncountries
        case .whss:
            return visited.whss
        case .beaches:
            return visited.beaches
        case .golfcourses:
            return visited.golfcourses
        case .divesites:
            return visited.divesites
        case .restaurants:
            return visited.restaurants
        case .hotels:
            return visited.hotels ?? []
        }
    }

    /// Accessor for distance to trigger a notification
    var triggerDistance: CLLocationDistance {
        switch self {
        case .locations:
            return 0
        case .uncountries:
            return 0
        case .whss:
            return 1_600
        case .beaches:
            return 1_600
        case .golfcourses:
            return 1_600
        case .divesites:
            return 1_600
        case .restaurants:
            return 100
        case .hotels:
            return 300
        }
    }

    /// Accessor for description to present in UI
    func names(full: Bool) -> (single: String, plural: String) {
        switch self {
        case .locations:
            return (L.location(), L.locations())
        case .uncountries:
            return (L.uncountry(), L.uncountries())
        case .whss:
            return (full ? L.whsFull() : L.whsShort(), L.whss())
        case .beaches:
            return (L.beach(), L.beaches())
        case .golfcourses:
            return (L.golfcourse(), L.golfcourses())
        case .divesites:
            return (L.divesite(), L.divesites())
        case .restaurants:
            return (L.restaurant(), L.restaurants())
        case .hotels:
            return (L.hotel(), L.hotels())
        }
    }

    /// Accessor for congratulations description
    func milestone(visited: Int) -> String {
        guard let milestones = data.get(milestones: self) else { return "" }
        return milestones.milestone(count: visited)
    }

    /// Whether this type can be displayed on the map
    var isMappable: Bool {
        switch self {
        case .uncountries: return false
        default: return true
        }
    }

    /// Timestamp accesssor
    var rankingsItem: Item {
        return (self, Timestamps.Info.rankings.rawValue)
    }

    /// Timestamp status
    var rankingsStatus: Timestamps.UpdateStatus {
        guard let updated = data.updated else {
            return Timestamps.UpdateStatus()
        }
        return updated.updateStatus(rankings: self)
    }

    /// Scorecard accesssor
    var scorecardItem: Item {
        return (self, Timestamps.Info.scorecard.rawValue)
    }

    /// Scorecard status
    var scorecardStatus: Timestamps.UpdateStatus {
        guard let updated = data.updated else {
            return Timestamps.UpdateStatus()
        }
        return updated.updateStatus(scorecard: self)
    }
}

/// Structure of Counts pages
enum Hierarchy {

    /// sort by brand then region then country
    case brandRegionCountry
    /// sort by region
    case region
    /// sort by region and country
    case regionCountry
    /// sort by region and country and location
    case regionCountryLocation
    /// sort by region and country, collapsing single location to country
    case regionCountryCombined
    /// sort by region then country then WHS with possible children
    case regionCountryWhs
    /// sort by region and display country as cell subtitle
    case regionSubtitled

    /// Whether to display cell subtitle
    var isCombined: Bool {
        return self == .regionCountryCombined
    }

    /// Whether to group by country
    var isGroupingByCountry: Bool {
        return !isSubtitled
    }

    /// Whether to display cell subtitle
    var isSubtitled: Bool {
        return self == .regionSubtitled
    }
}

extension Checklist {

    /// Structure of Counts pages
    var hierarchy: Hierarchy {
        switch self {
        case .locations:
            return .regionCountryCombined
        case .uncountries:
            return .region
        case .whss:
            return .regionCountryWhs
        case .beaches:
            return .regionSubtitled
        case .golfcourses:
            return .regionSubtitled
        case .divesites:
            return .regionSubtitled
        case .restaurants:
            return .regionCountryLocation
        case .hotels:
            if data.hotelsGroupBrand {
                return .brandRegionCountry
            } else {
                return .regionCountry
            }
        }
    }
}

/// Mapping to bridge Checklist with UI tests' identifiers
extension ChecklistIndex {

    /// returns enum of Int value for accessibilityIdentifier
    init(list: Checklist) {
        switch list {
        case .locations: self = .locations
        case .uncountries: self = .uncountries
        case .whss: self = .whss
        case .beaches: self = .beaches
        case .golfcourses: self = .golfcourses
        case .divesites: self = .divesites
        case .restaurants: self = .restaurants
        case .hotels: self = .hotels
        }
    }
}
