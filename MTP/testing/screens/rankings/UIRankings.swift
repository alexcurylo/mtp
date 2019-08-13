// @copyright Trollwerks Inc.

/// RankingsVC exposed items
enum UIRankings: Exposable {

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
