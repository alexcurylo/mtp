// @copyright Trollwerks Inc.

/// LocationsVC exposed items
enum UILocations: Exposable {

    /// Navigation bar
    case nav
    /// Filter bar button
    case filter
    /// Nearby bar button
    case nearby
    /// Search field

    /// Search field
    case search
    /// Cancel button
    case cancel
    /// Results list item
    case result(Row)

    /// Callout close
    case close
    /// Callout switch
    case visit
    /// Callout directions
    case directions
    /// Callout More Info
    case more
}
