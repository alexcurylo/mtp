// @copyright Trollwerks Inc.

import RealmSwift

/// Posts endpoints reply
struct PostsJSON: Codable {

    /// HTTP result code
    let code: Int
    /// List of posts
    let data: [PostJSON]
    // swiftlint:disable:next discouraged_optional_boolean
    private let paging: Bool? // not in locations, always false for user
}

extension PostsJSON: CustomStringConvertible {

    var description: String {
        return "PostsJSON: \(data.count)"
    }
}

extension PostsJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PostsJSON: \(description):
        code: \(code)
        paging: \(String(describing: paging))
        data: \(data.debugDescription)
        /PostsJSON >
        """
    }
}

/// Post info received from MTP endpoints
struct PostJSON: Codable {

    fileprivate let createdAt: Date
    fileprivate let id: Int
    fileprivate let location: PlaceLocation // LocationJSON in user endpoint
    fileprivate let locationId: Int
    fileprivate let post: String?
    fileprivate let status: String
    fileprivate let updatedAt: Date
    /// owner
    let owner: OwnerJSON? // UserJSON in user endpoint
    /// userId
    let userId: Int // appears filled in even if owner null
}

extension PostJSON: CustomStringConvertible {

    var description: String {
        return "PostJSON: \(locationId), \(id)"
    }
}

extension PostJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PostJSON: \(description):
        createdAt: \(createdAt)
        id: \(id)
        location: \(location)
        locationId: \(locationId)
        post: \(String(describing: post))
        status: \(status)
        updatedAt: \(updatedAt)
        owner: \(String(describing: owner))
        userId: \(userId)
        /PostJSON >
        """
    }
}

/// Realm representation of a post
@objcMembers final class Post: Object {

    /// locationId
    dynamic var locationId: Int = 0
    /// post
    dynamic var post: String = ""
    /// postId
    dynamic var postId: Int = 0
    /// updatedAt
    dynamic var updatedAt = Date()
    /// userId
    dynamic var userId: Int = 0

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "postId"
    }

    /// Constructor from MTP endpoint data
    convenience init?(from: PostJSON) {
        guard let text = from.post,
              !text.isEmpty,
              from.owner != nil,
              from.status == MTP.Status.published.rawValue else {
            return nil
        }

        self.init()

        locationId = from.locationId
        post = text
        postId = from.id
        updatedAt = from.updatedAt
        userId = from.userId
    }
}
