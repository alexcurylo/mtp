// @copyright Trollwerks Inc.

/// PhoneItem
struct UserPhoneItem: FeedbackItemProtocol {

    /// phone
    var phone: String?

    /// :nodoc:
    let isHidden: Bool

    /// :nodoc:
    init(isHidden: Bool) { self.isHidden = isHidden }
}
