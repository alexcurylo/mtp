// @copyright Trollwerks Inc.

/// LocationSearchVC exposed items
enum UILocationSearch: Exposable {

    /// Close bar button
    case close

    /// Search field
    case search
    /// Cancel button
    case cancel

    /// Results list item
    case result(Row)
}
