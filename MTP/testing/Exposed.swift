// @copyright Trollwerks Inc.

private enum Exposed {

    case locationsVCs
    case mainTBCs
    case myProfileVCs
    case nearbyVCs
    case profileVCs
    case rankingVCs
}

/// Enhance readability
typealias Rank = Int

/// Mapping to bridge Checklist with UI tests' identifiers
enum ChecklistIndex: Int, CustomStringConvertible {

    /// Checklist .locations as 0
    case locations
    /// Checklist .uncountries as 1
    case uncountries
    /// Checklist .whss as 2
    case whss
    /// Checklist .beaches as 3
    case beaches
    /// Checklist .golfcourses as 4
    case golfcourses
    /// Checklist .divesites as 5
    case divesites
    /// Checklist .restaurants as 6
    case restaurants

    var description: String {
        return "\(rawValue)"
    }
}

/// LocationVC exposed items
enum LocationsVCs: Exposable {

    /// Navigation bar
    case nav
    /// Filter bar button
    case filter
    /// Nearby bar button
    case nearby
}

/// MainTBC exposed items
enum MainTBCs: Exposable {

    /// Main tab bar
    case bar
    /// Locations tab button
    case locations
    /// Rankings tab button
    case rankings
    /// My Profile tab button
    case myProfile
}

/// MyProfileVC exposed items
enum MyProfileVCs: Exposable {

    /// Tab menu
    case menu
    /// About tab button
    case about
    /// Counts tab button
    case counts
    /// Photos tab button
    case photos
    /// Posts tab button
    case posts
}

/// NearbyVC exposed items
enum NearbyVCs: Exposable {

    /// Close bar button
    case close

    /// Places table
    case places
    /// Places cell
    case place(Rank)
}

/// UserProfileVC exposed items
enum UserProfileVCs: Exposable {

    /// Close bar button
    case close
}

/// RankingVC exposed items
enum RankingVCs: Exposable {

    /// Navigation bar
    case nav
    /// Filter bar button
    case filter
    /// Search bar button
    case search

    /// Header button for list ranks
    case ranks(ChecklistIndex)
    /// Profile cell
    case profile(ChecklistIndex, Rank)
    /// Profile cell Remaining button
    case remaining(ChecklistIndex, Rank)
    /// Profile cell Visited button
    case visited(ChecklistIndex, Rank)
}
