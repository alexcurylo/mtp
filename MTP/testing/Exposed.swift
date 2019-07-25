// @copyright Trollwerks Inc.

enum Exposed {

    case locationsVCs
    case mainTBCs
    case myProfileVCs
    case nearbyVCs
    case profileVCs
    case rankingVCs
}

typealias Rank = Int

enum ChecklistIndex: Int, CustomStringConvertible {

    case locations
    case uncountries
    case whss
    case beaches
    case golfcourses
    case divesites
    case restaurants

    var description: String {
        return "\(rawValue)"
    }
}

enum LocationsVCs: Exposable {
    case nav
    case filter
    case nearby
}

enum MainTBCs: Exposable {
    case bar
    case locations
    case rankings
    case myProfile
}

enum MyProfileVCs: Exposable {
    case menu
    case about
    case counts
    case photos
    case posts
}

enum NearbyVCs: Exposable {
    case close

    case places
    case place(Rank)
}

enum UserProfileVCs: Exposable {
    case close
}

enum RankingVCs: Exposable {
    case nav
    case filter
    case search

    case ranks(ChecklistIndex)
    case profile(ChecklistIndex, Rank)
    case remaining(ChecklistIndex, Rank)
    case visited(ChecklistIndex, Rank)
}
