// @copyright Trollwerks Inc.

/// RankingsVC exposed items
enum UIRankings: Exposable {

    /// Navigation bar
    case nav
    /// Filter bar button
    case filter
    /// Find bar button
    case find

    /// Search field
    case search
    /// Cancel button
    case cancel

    /// Results list item
    case result(Row)
}
