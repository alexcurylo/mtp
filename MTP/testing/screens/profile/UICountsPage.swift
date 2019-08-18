// @copyright Trollwerks Inc.

/// CountsPageVC exposed items
enum UICountsPage: Exposable {

    /// Counts section header
    case region(Section)
    /// Expandable cell under header
    case group(Section, Row)
    /// Not expandable cell under header
    case item(Section, Row)
    /// Visisted switch in item cell
    case toggle(Section, Row)
}
