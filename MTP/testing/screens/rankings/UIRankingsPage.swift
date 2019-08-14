// @copyright Trollwerks Inc.

/// RankingsPageVC exposed items
enum UIRankingsPage: Exposable {

    /// Collection view for list ranks
    case ranks(ChecklistIndex)
    /// Profile cell
    case profile(ChecklistIndex, Rank)
    /// Profile cell Remaining button
    case remaining(ChecklistIndex, Rank)
    /// Profile cell Visited button
    case visited(ChecklistIndex, Rank)
}
