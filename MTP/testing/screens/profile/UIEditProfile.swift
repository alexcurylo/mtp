// @copyright Trollwerks Inc.

/// EditProfileVC exposed items
enum UIEditProfile: Exposable {

    /// Close bar button
    case close
    /// Save bar button
    case save

    /// Change avatar
    case avatar
    /// First name text field
    case first
    /// Last name text field
    case last
    /// Birthday text field for date picker
    case birthday
    /// Gender text field
    case gender
    /// Country text field for list triggering
    case country
    /// Location text field for list triggering
    case location
    /// Email text field
    case email
    /// About text view
    case about
    /// Airport text field
    case airport
    /// Link title text field
    case linkTitle(Row)
    /// Link URL text field
    case linkUrl(Row)
    /// Delete link button
    case linkDelete(Row)
    /// Add link button
    case linkAdd
}
